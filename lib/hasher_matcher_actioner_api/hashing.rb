# frozen_string_literal: true

module HasherMatcherActionerApi
  module Hashing
    class HashResult < Dry::Struct
      HasherMatcherActionerApi::Configuration::SIGNAL_TYPES.each do |type|
        attribute? type, Types::String.optional
      end
    end

    def hash_url(url, content_type: nil, signal_types: nil)
      validate_content_type!(content_type)
      validate_signal_types!(signal_types)

      params = {url: url}
      params[:content_type] = content_type if content_type
      params[:types] = signal_types.join(",") if signal_types

      HashResult.new(get("/h/hash", params))
    end

    def hash_file(file, content_type:)
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

      HashResult.new(post("/h/hash", payload))
    end

    private

    def validate_content_type!(content_type)
      if content_type && !Configuration::CONTENT_TYPES.include?(content_type)
        raise ValidationError, "content_type must be one of: #{Configuration::CONTENT_TYPES.join(", ")}, received: #{content_type}"
      end
    end

    def validate_signal_types!(signal_types)
      if signal_types&.any? { |signal_type| !Configuration::SIGNAL_TYPES.include?(signal_type) }
        raise ValidationError, "signal types must be one of: #{Configuration::SIGNAL_TYPES.join(", ")}, received: #{signal_types.join(", ")}"
      end
    end
  end
end
