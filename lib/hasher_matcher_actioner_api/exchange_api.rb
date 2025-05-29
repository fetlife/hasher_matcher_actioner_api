# frozen_string_literal: true

module HasherMatcherActionerApi
  module ExchangeAPI
    class Config < Dry::Struct
      attribute :name, HasherMatcherActionerApi::Types::String

      attribute? :supports_authentification, HasherMatcherActionerApi::Types::Bool.optional
      attribute? :has_set_authentification, HasherMatcherActionerApi::Types::Bool.optional

      def valid?
        return true unless supports_authentification
        has_set_authentification
      end

      def validate!
        return if valid?
        raise HasherMatcherActionerApi::ApiNotConfiguredError, "Exchange #{name} requires authentication, but has not been set"
      end
    end

    SAMPLE = "sample".freeze
    INFINITE_RANDOM = "infinite_random".freeze
    FB_THREAT_EXCHANGE = "fb_threatexchange".freeze
    NCMEC = "ncmec".freeze
    STOP_NCII = "stop_ncii".freeze

    SUPPORTED_EXCHANGES = [
      SAMPLE,
      INFINITE_RANDOM,
      FB_THREAT_EXCHANGE,
      NCMEC,
      STOP_NCII
    ].freeze

    def get_exchange_api_config(name:)
      validate_exchange_name!(name)
      Config.new(get("/c/exchanges/api/#{name}"))
    end

    def update_exchange_api_config(name:, credential_json:)
      validate_exchange_name!(name)
      config = Config.new(name:, **post("/c/exchanges/api/#{name}", { credential_json: }))
      config.validate!
      config
    end

    def list_exchange_apis
      get("/c/exchanges/apis").map do |api|
        Config.new(name: api)
      end
    end

    def require_exchange_apis_enabled!(names:)
      configured_apis = list_exchange_apis.map(&:name)

      names.each do |name|
        validate_exchange_name!(name)
        validate_exchange_enabled!(name, configured_apis)
      end

      true
    end

    def require_exchange_apis_configured!(names:)
      require_exchange_apis_enabled!(names:)

      names.each do |name|
        config = get_exchange_api_config(name:)
        config.validate!
      end

      true
    end

    private

    def validate_exchange_name!(name)
      return if SUPPORTED_EXCHANGES.include?(name)

      raise HasherMatcherActionerApi::ArgumentError, 
            "Exchange '#{name}' is not supported. Supported exchanges: #{SUPPORTED_EXCHANGES.join(', ')}"
    end

    def validate_exchange_enabled!(name, configured_apis)
      return if configured_apis.include?(name)

      raise HasherMatcherActionerApi::ApiNotConfiguredError, 
            "Exchange '#{name}' is not configured. Add it to exchange_types in hasher-matcher-actioner config.py"
    end
  end
end 