# frozen_string_literal: true

module HasherMatcherActionerApi
  module Exchanges

    class Exchange < Dry::Struct
      attribute :name, HasherMatcherActionerApi::Types::String
      attribute :api, HasherMatcherActionerApi::Types::String
      attribute :enabled, HasherMatcherActionerApi::Types::Bool.default(true)

      # NCMEC specific configuration
      attribute? :only_esp_ids, HasherMatcherActionerApi::Types::Array.of(HasherMatcherActionerApi::Types::Integer)
      attribute? :environment, HasherMatcherActionerApi::Types::String.constrained(included_in: %w[production staging development])
    end
    
    def create_exchange(api:, bank:, api_json:)
      post('/c/exchanges', {
        api:,
        bank:,
        api_json:,
      })

      get_exchange(name: bank)
    end

    def get_exchange(name:)
      Exchange.new(get("/c/exchange/#{name}"))
    end

    def exchange_exists?(name:)
      get_exchange(name:)
      true
    rescue NotFoundError
      false
    end
  end
end
