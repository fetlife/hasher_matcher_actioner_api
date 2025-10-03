# frozen_string_literal: true

module HasherMatcherActionerApi
  module Matching
    class NormalizedMatch < Dry::Struct
      attribute :signal_type, Types::Coercible::String
      attribute :bank_name, Types::Coercible::String
      attribute :bank_content_id, Types::Integer
      attribute :distance, Types::Coercible::Integer
    end

    class MatchWithDistance < Dry::Struct
      attribute :bank_content_id, Types::Integer
      attribute :distance, Types::Coercible::Integer
    end

    class MatchesResult < Dry::Struct
      attribute :matches, Types::Array.of(Types::Integer)
    end

    class MatchesResultWithDistance < Dry::Struct
      attribute :matches, Types::Array.of(MatchWithDistance)
    end

    class LookupResult < Dry::Struct
      include HasherMatcherActionerApi::SignalAttributes

      add_signal_attributes(Types::Hash.map(Types::Coercible::String, Types::Array(MatchWithDistance)))

      def normalized_matches
        attributes.map do |signal_type, matches_by_bank|
          matches_by_bank.map do |bank_name, matches|
            matches.map do |match|
              NormalizedMatch.new(signal_type: signal_type.to_s, bank_name:, bank_content_id: match.bank_content_id, distance: match.distance)
            end
          end
        end.flatten
      end
    end

    def raw_lookup(signal, signal_type:, include_distance: false)
      validate_signal_types!([signal_type])

      params = {
        signal: signal,
        signal_type: signal_type,
        include_distance: include_distance
      }

      res = get("/m/raw_lookup", params)

      if include_distance
        MatchesResultWithDistance.new(res)
      else
        MatchesResult.new(res)
      end
    end

    def lookup_url(url, content_type: nil, signal_types: nil)
      validate_content_type!(content_type)
      validate_signal_types!(signal_types)

      params = {url: url}
      params[:content_type] = content_type if content_type
      params[:types] = signal_types.join(",") if signal_types

      res = LookupResult.new(get("/m/lookup", params))
      res.normalized_matches
    end

    def lookup_file(file, content_type:)
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

      res = LookupResult.new(post("/m/lookup", payload))
      res.normalized_matches
    end
  end
end
