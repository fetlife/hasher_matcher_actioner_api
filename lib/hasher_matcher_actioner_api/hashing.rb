# frozen_string_literal: true

module HasherMatcherActionerApi
  module Hashing
    class HashResult < Dry::Struct
      HasherMatcherActionerApi::Configuration::SIGNAL_TYPES.each do |type|
        attribute? type, Types::String.optional
      end
    end

    def hash_url(url:, content_type: nil, types: nil)
      if content_type && !Configuration::CONTENT_TYPES.include?(content_type)
        raise ValidationError, "content_type must be one of: #{Configuration::CONTENT_TYPES.join(', ')}"
      end

      if types && !types.all? { |type| Configuration::SIGNAL_TYPES.include?(type) }
        raise ValidationError, "types must be one of: #{Configuration::SIGNAL_TYPES.join(', ')}"
      end

      params = { url: url }
      params[:content_type] = content_type if content_type
      params[:types] = types if types

      HashResult.new(get('/h/hash', params))
    end

    def hash_file(file:, content_type: nil)
      if content_type && !Configuration::CONTENT_TYPES.include?(content_type)
        raise ValidationError, "content_type must be one of: #{Configuration::CONTENT_TYPES.join(', ')}"
      end

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

      HashResult.new(post('/h/hash', payload))
    end
  end
end
