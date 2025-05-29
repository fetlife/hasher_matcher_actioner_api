# frozen_string_literal: true

require 'faraday'
require 'json'
require 'logger'

require_relative 'banks'
require_relative 'exchanges'
require_relative 'hashing'
require_relative 'matching'
require_relative 'exchange_api'

module HasherMatcherActionerApi
  class Client
    include Banks
    include Exchanges
    include Hashing
    include Matching
    include ExchangeAPI
    
    attr_reader :conn

    DEFAULT_TIMEOUT = 3
    MAX_RETRIES = 3
    DEFAULT_LOG_LEVEL = :info

    def initialize(
      base_url:,
      timeout: DEFAULT_TIMEOUT,
      log_level: DEFAULT_LOG_LEVEL
    )
      @logger = logger || Logger.new($stdout)
      @logger.level = log_level

      @conn = Faraday.new(url: base_url) do |f|
        f.request :json
        
        f.request :retry, {
          max: MAX_RETRIES,
          interval: 0.5,
          interval_randomness: 0.5,
          backoff_factor: 2,
          retry_statuses: [408, 429, 500, 502, 503, 504],
          exceptions: [
            'Faraday::TimeoutError',
            'Faraday::ConnectionFailed',
            'Faraday::RetriableResponse'
          ]
        }

        f.response :logger, nil, {
          headers: log_level == :debug || log_level == :trace,
          bodies: log_level == :trace,
          errors: true,
          log_level: log_level,
        }
        f.response :json, parser_options: { symbolize_names: true }

        f.options.timeout = timeout
        f.options.open_timeout = timeout * 2
        
        f.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      res = conn.get(path, params)
      handle_response(res)
    end

    def post(path, body = nil)
      res = conn.post(path, body)
      handle_response(res)
    end

    # def put(path, body = nil)
    #   res = conn.put(path, body)
    #   handle_response(res)
    # end

    # def upload(path, file:, type:)
    #   upload_file = Faraday::UploadIO.new(file, type)
    #   res = conn.post(path, { file.key => upload_file })
    #   handle_response(res)
    # end

    # def multipart(path, payload)
    #   res = conn.post(path, payload)
    #   handle_response(res)
    # end

    private

    def handle_response(response)
      case response.status
      when 200..299
        response.body
      when 400
        error = response.body
        raise ValidationError, "Invalid request: #{error['message']}"
      when 401
        raise AuthenticationError, "Authentication required"
      when 403
        raise PermissionError, "Permission denied: Required role not enabled"
      when 404
        raise NotFoundError, "Resource not found"
      when 500
        raise ServerError, "Internal server error: #{response.body}"
      else
        raise Error, "Unexpected error: #{response.status} - #{response.body}"
      end
    end
  end
end


