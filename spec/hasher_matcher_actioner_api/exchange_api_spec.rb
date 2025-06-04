# frozen_string_literal: true

require "spec_helper"

RSpec.describe HasherMatcherActionerApi::Client do
  let(:client) { described_class.new(base_url: "http://127.0.0.1:5050", max_retries: 0) }

  describe "#get_exchange_api_config" do
    it "retrieves exchange API config successfully", :vcr do
      result = client.get_exchange_api_config(name: "sample")
      expect(result.name).to eq("sample")
      expect(result.supports_authentification).to be(false)
      expect(result.has_set_authentification).to be(false)
    end
  end

  describe "#update_exchange_api_config" do
    it "updates exchange API config successfully", :vcr do
      result = client.update_exchange_api_config(name: "ncmec", credential_json: {
        user: "user",
        password: "password"
      })
      expect(result.name).to eq("ncmec")
      expect(result.supports_authentification).to be(true)
      expect(result.has_set_authentification).to be(true)
    end
  end

  describe "#list_exchange_apis" do
    it "lists exchange APIs successfully", :vcr do
      result = client.list_exchange_apis
      expect(result).to be_an(Array)
      expect(result.first.name).to eq("sample")
    end
  end

  describe "#require_exchange_apis_enabled!" do
    it "returns true if all exchanges are enabled", :vcr do
      expect(client.require_exchange_apis_enabled!(names: ["sample"])).to be(true)
    end
  end

  describe "#require_exchange_apis_configured!" do
    it "returns true if all exchanges are configured", :vcr do
      expect(client.require_exchange_apis_configured!(names: ["ncmec"])).to be(true)
    end

    it "raises an error if not all exchanges are configured", :vcr do
      expect {
        client.require_exchange_apis_configured!(names: ["stop_ncii"])
      }.to raise_error(HasherMatcherActionerApi::ApiNotConfiguredError)
    end
  end
end
