# frozen_string_literal: true

require "spec_helper"

RSpec.describe HasherMatcherActionerApi::Client do
  let(:client) { described_class.new(base_url: "http://127.0.0.1:5050", max_retries: 0) }

  describe "#hash_url" do
    let(:url) { "https://i.ibb.co/wF7823P1/image-in-hash-db.jpg" }
    let(:valid_content_type) { "photo" }
    let(:valid_signal_types) { ["pdq"] }

    context "with valid parameters" do
      it "returns hash result with all signal types", :vcr do
        result = client.hash_url(url)
        expect(result.pdq).to eq(HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH)
      end

      context "with content type" do
        it "returns hash result with content type", :vcr do
          result = client.hash_url(url, content_type: valid_content_type)
          expect(result.pdq).to eq(HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH)
        end
      end

      context "with signal types" do
        it "returns hash result with specified signal types", :vcr do
          result = client.hash_url(url, signal_types: valid_signal_types)
          expect(result.pdq).to eq(HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH)
        end
      end
    end

    context "with invalid parameters" do
      it "raises error for invalid content type" do
        expect {
          client.hash_url(url, content_type: "invalid_type")
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end

      it "raises error for invalid signal types" do
        expect {
          client.hash_url(url, signal_types: ["invalid_type"])
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end
    end
  end

  describe "#hash_file" do
    let(:file) { File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "image-in-hash-db.jpg")) }
    let(:valid_content_type) { "photo" }

    context "with valid parameters" do
      it "returns hash result", vcr: {match_requests_on: [:method, :uri]} do
        result = client.hash_file(file, content_type: valid_content_type)
        expect(result.pdq).to eq(HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH)
      end
    end

    context "with invalid parameters" do
      it "raises error for missing content type" do
        expect {
          client.hash_file(file, content_type: nil)
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end

      it "raises error for invalid content type" do
        expect {
          client.hash_file(file, content_type: "invalid_type")
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end

      it "raises error for non-IO object" do
        expect {
          client.hash_file("not a file", content_type: valid_content_type)
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end
    end
  end
end
