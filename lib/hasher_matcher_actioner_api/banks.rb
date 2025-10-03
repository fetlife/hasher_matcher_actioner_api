# frozen_string_literal: true

module HasherMatcherActionerApi
  module Banks
    class Bank < Dry::Struct
      attribute :name, HasherMatcherActionerApi::Types::String
      attribute :matching_enabled_ratio, HasherMatcherActionerApi::Types::Float.constrained(gteq: 0.0, lteq: 1.0)
      attribute :enabled, HasherMatcherActionerApi::Types::Bool.default(true)
    end

    class BankContentResult < Dry::Struct
      attribute :id, HasherMatcherActionerApi::Types::Integer

      # Nested signals structure with dynamic signal type attributes
      class Signals < Dry::Struct
        include HasherMatcherActionerApi::SignalAttributes

        add_signal_attributes
      end

      attribute :signals, Signals
    end

    def create_bank(name:, enabled: true, matching_enabled_ratio: 1.0)
      res = post("/c/banks", {
        name:,
        enabled: enabled.to_s,
        matching_enabled_ratio:
      })
      Bank.new(res)
    end

    def get_bank(name:)
      Bank.new(get("/c/bank/#{name}"))
    end

    def bank_exists?(name:)
      get_bank(name:)
      true
    rescue NotFoundError
      false
    end

    def add_url_to_bank(bank_name:, url:, content_type: nil, metadata: nil)
      validate_content_type!(content_type)

      params = {url: url}
      params[:content_type] = content_type if content_type
      params[:metadata] = metadata.to_json if metadata.is_a?(Hash)

      # Use POST with query parameters for URL-based content
      res = post("/c/bank/#{bank_name}/content", nil, params)
      BankContentResult.new(res)
    end

    def add_file_to_bank(bank_name:, file:, content_type:, metadata: nil)
      validate_content_type!(content_type)

      unless file.respond_to?(:read)
        raise ValidationError, "file must be an IO-like object that responds to #read"
      end

      unless content_type
        raise ValidationError, "content_type is required for file uploads"
      end

      mime_type = Marcel::MimeType.for(file)
      payload = {
        content_type => Faraday::Multipart::FilePart.new(file, mime_type)
      }

      # Add metadata if provided
      if metadata
        payload[:metadata] = metadata.to_json if metadata.is_a?(Hash)
      end

      res = post("/c/bank/#{bank_name}/content", payload)
      BankContentResult.new(res)
    end
  end
end
