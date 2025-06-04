# frozen_string_literal: true

module HasherMatcherActionerApi
  module Exchanges
    class Exchange < Dry::Struct
      attribute :name, HasherMatcherActionerApi::Types::String
      attribute :api, HasherMatcherActionerApi::Types::String
      attribute :enabled, HasherMatcherActionerApi::Types::Bool.default(true)

      # NCMEC specific configuration
      attribute? :only_esp_ids, HasherMatcherActionerApi::Types::Array.of(HasherMatcherActionerApi::Types::Integer)
      attribute? :environment, HasherMatcherActionerApi::Types::String
    end

    class ExchangeStatus < Dry::Struct
      attribute :checkpoint_ts, HasherMatcherActionerApi::Types::Integer.optional
      attribute :fetched_items, HasherMatcherActionerApi::Types::Integer
      attribute :last_fetch_complete_ts, HasherMatcherActionerApi::Types::Integer.optional
      attribute :last_fetch_succeeded, HasherMatcherActionerApi::Types::Bool.optional
      attribute :running_fetch_start_ts, HasherMatcherActionerApi::Types::Integer.optional
      attribute :up_to_date, HasherMatcherActionerApi::Types::Bool
    end

    def create_exchange(api:, bank:, api_json:)
      post("/c/exchanges", {
        api:,
        bank:,
        api_json:
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

    def get_exchange_fetch_status(name:)
      ExchangeStatus.new(get("/c/exchange/#{name}/status"))
    end
  end
end
