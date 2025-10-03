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

    # {
    #   "matches": [
    #     {
    #       "bank_content_id": 4
    #     }
    #   ]
    # }
    class MatchesResult < Dry::Struct
      attribute :matches, Types::Array.of(Types::Integer)
    end

    # {
    #   "matches": [
    #     {
    #       "bank_content_id": 4,
    #       "distance": "0"
    #     }
    #   ]
    # }
    class MatchesResultWithDistance < Dry::Struct
      attribute :matches, Types::Array.of(MatchWithDistance)
    end

    # {
    #   "pdq": {
    #     "BANK": [
    #       {
    #         "bank_content_id": 4,
    #         "distance": "0"
    #       }
    #     ]
    #   }
    # }
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

    # {
    #   "BANK_NAME": [
    #     {
    #       "bank_content_id": 66,
    #       "distance": "0"
    #     }
    #   ],
    #   "BANK_NAME_2": [
    #     {
    #       "bank_content_id": 4,
    #       "distance": "0"
    #     }
    #   ]
    # }
    class LookupSignalResult < Dry::Struct
      # The response is a flat hash where keys are bank names and values are arrays of matches
      # We need to handle this as a flexible hash structure with string keys
      transform_keys(&:to_sym)

      # Define a flexible hash attribute that can handle any string key with array of MatchWithDistance values
      attribute :matches_by_bank, Types::Hash.map(Types::Coercible::String, Types::Array(MatchWithDistance))

      def normalized_matches(signal_type)
        normalized_matches = []
        matches_by_bank.each do |bank_name, matches|
          matches.each do |match|
            normalized_matches << NormalizedMatch.new(
              signal_type: signal_type,
              bank_name: bank_name.to_s,
              bank_content_id: match.bank_content_id,
              distance: match.distance
            )
          end
        end
        normalized_matches
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

    def lookup_signal(signal, signal_type)
      validate_signal_types!([signal_type])

      params = {
        signal: signal,
        signal_type: signal_type
      }

      res = LookupSignalResult.new(matches_by_bank: get("/m/lookup", params))
      res.normalized_matches(signal_type)
    end
  end
end
