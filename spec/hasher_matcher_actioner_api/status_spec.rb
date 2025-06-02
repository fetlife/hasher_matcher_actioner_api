# frozen_string_literal: true

require "spec_helper"

RSpec.describe HasherMatcherActionerApi::Client do
  let(:client) { described_class.new(base_url: "http://localhost:5000", max_retries: 0) }

  describe "#status" do
    context "when service is healthy" do
      before do
        stub_successful_response(
          :get,
          "/status",
          query: {},
          body: "I-AM-ALIVE"
        )
      end

      it "returns I-AM-ALIVE" do
        expect(client.status.alive?).to eq(true)
        expect(client.status.stale?).to eq(false)
      end
    end

    context "when index is stale" do
      before do
        stub_response(
          :get,
          "/status",
          query: {},
          body: "INDEX-STALE",
          status: 503
        )
      end

      it "returns INDEX-STALE" do
        expect(client.status.alive?).to eq(false)
        expect(client.status.stale?).to eq(true)
      end
    end
  end

  describe "#server_ready?" do
    context "when service is healthy" do
      before do
        stub_successful_response(
          :get,
          "/status",
          query: {},
          body: "I-AM-ALIVE"
        )
      end

      it "returns true" do
        expect(client.server_ready?).to be(true)
      end
    end

    context "when service is not healthy" do
      before do
        stub_response(
          :get,
          "/status",
          query: {},
          body: "INDEX-STALE",
          status: 503
        )
      end

      it "returns false" do
        expect(client.server_ready?).to be(false)
      end
    end
  end
end
