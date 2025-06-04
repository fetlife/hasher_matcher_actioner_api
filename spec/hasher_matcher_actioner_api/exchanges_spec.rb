# frozen_string_literal: true

require "spec_helper"

RSpec.describe HasherMatcherActionerApi::Client do
  let(:client) { described_class.new(base_url: "http://127.0.0.1:5050", max_retries: 0) }

  describe "#create_exchange" do
    it "creates an exchange successfully", :vcr do
      result = client.create_exchange(api: "sample", bank: "NEW_BANK_NAME", api_json: {})
      expect(result.name).to eq("NEW_BANK_NAME")
      expect(result.api).to eq("sample")
      expect(result.enabled).to be(true)
    end
  end

  describe "#get_exchange" do
    it "retrieves an exchange successfully", :vcr do
      result = client.get_exchange(name: "NEW_BANK_NAME")
      expect(result.name).to eq("NEW_BANK_NAME")
    end
  end

  describe "#exchange_exists?" do
    it "returns true if exchange exists", :vcr do
      expect(client.exchange_exists?(name: "NEW_BANK_NAME")).to be(true)
    end

    it "returns false if exchange does not exist", :vcr do
      expect(client.exchange_exists?(name: "NON_EXISTENT_EXCHANGE")).to be(false)
    end
  end

  describe "#get_exchange_fetch_status" do
    it "retrieves exchange fetch status successfully", :vcr do
      result = client.get_exchange_fetch_status(name: "NEW_BANK_NAME")
      expect(result).to respond_to(:checkpoint_ts)
      expect(result).to respond_to(:fetched_items)
      expect(result).to respond_to(:last_fetch_complete_ts)
      expect(result).to respond_to(:last_fetch_succeeded)
      expect(result).to respond_to(:running_fetch_start_ts)
      expect(result).to respond_to(:up_to_date)
    end
  end
end
