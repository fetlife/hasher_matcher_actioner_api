# frozen_string_literal: true

require "spec_helper"

RSpec.describe HasherMatcherActionerApi::Client do
  let(:client) { described_class.new(base_url: "http://127.0.0.1:5050", max_retries: 0) }

  describe "#create_bank" do
    it "creates a bank successfully", :vcr do
      result = client.create_bank(name: "TEST_BANK", enabled: true, matching_enabled_ratio: 1.0)
      expect(result.name).to eq("TEST_BANK")
      expect(result.enabled).to be(true)
      expect(result.matching_enabled_ratio).to eq(1.0)
    end

    it "raises an error if the bank already exists", :vcr do
      expect {
        client.create_bank(name: "TEST_BANK", enabled: true, matching_enabled_ratio: 1.0)
      }.to raise_error(HasherMatcherActionerApi::ResourceAlreadyExistsError)
    end

    it "raises an error if the bank name is invalid", :vcr do
      expect {
        client.create_bank(name: "bad_name", enabled: true, matching_enabled_ratio: 1.0)
      }.to raise_error(HasherMatcherActionerApi::ValidationError)
    end
  end

  describe "#get_bank" do
    it "retrieves a bank successfully", :vcr do
      result = client.get_bank(name: "TEST_BANK")
      expect(result.name).to eq("TEST_BANK")
    end
  end

  describe "#bank_exists?" do
    it "returns true if bank exists", :vcr do
      expect(client.bank_exists?(name: "TEST_BANK")).to be(true)
    end

    it "returns false if bank does not exist", :vcr do
      expect(client.bank_exists?(name: "NON_EXISTENT_BANK")).to be(false)
    end
  end
end
