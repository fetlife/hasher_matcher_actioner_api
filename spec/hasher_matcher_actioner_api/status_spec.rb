# frozen_string_literal: true

require "spec_helper"

RSpec.describe HasherMatcherActionerApi::Client do
  let(:client) { described_class.new(base_url: "http://127.0.0.1:5050", max_retries: 0) }

  describe "#status" do
    context "when service is healthy" do
      it "returns healthy status", :vcr do
        result = client.status
        expect(result.status).to eq("I-AM-ALIVE")
      end
    end

    context "when service is unhealthy" do
      it "returns unhealthy status", :vcr do
        result = client.status
        expect(result.status).to eq("INDEX-STALE")
      end
    end
  end

  describe "#server_ready?" do
    context "when service is healthy" do
      it "returns true", :vcr do
        expect(client.server_ready?).to be(true)
      end
    end

    context "when service is not healthy" do
      it "returns false", :vcr do
        expect(client.server_ready?).to be(false)
      end
    end
  end
end
