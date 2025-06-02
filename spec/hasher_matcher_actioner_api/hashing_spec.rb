# frozen_string_literal: true

require "spec_helper"

RSpec.describe HasherMatcherActionerApi::Client do
  let(:client) { described_class.new(base_url: "http://localhost:5000", max_retries: 0) }

  describe "#hash_url" do
    let(:url) { "https://example.com/image.jpg" }
    let(:valid_content_type) { "photo" }
    let(:valid_signal_types) { ["pdq", "video_md5"] }

    context "with valid parameters" do
      before do
        stub_successful_response(
          :get,
          "/h/hash",
          query: {url: url},
          body: {pdq: "hash123", video_md5: "hash456"}
        )
      end

      it "returns hash result with all signal types" do
        result = client.hash_url(url)
        expect(result.pdq).to eq("hash123")
        expect(result.video_md5).to eq("hash456")
      end

      context "with content type" do
        before do
          stub_successful_response(
            :get,
            "/h/hash",
            query: {url: url, content_type: valid_content_type},
            body: {pdq: "hash123"}
          )
        end

        it "returns hash result with content type" do
          result = client.hash_url(url, content_type: valid_content_type)
          expect(result.pdq).to eq("hash123")
        end
      end

      context "with signal types" do
        before do
          stub_successful_response(
            :get,
            "/h/hash",
            query: {url: url, types: valid_signal_types.join(",")},
            body: {pdq: "hash123", video_md5: "hash456"}
          )
        end

        it "returns hash result with specified signal types" do
          result = client.hash_url(url, signal_types: valid_signal_types)
          expect(result.pdq).to eq("hash123")
          expect(result.video_md5).to eq("hash456")
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
    let(:file) { StringIO.new("test content") }
    let(:valid_content_type) { "photo" }

    context "with valid parameters" do
      before do
        stub_successful_post(
          "/h/hash",
          body: {pdq: "hash123", video_md5: "hash456"}
        )
      end

      it "returns hash result" do
        result = client.hash_file(file, content_type: valid_content_type)
        expect(result.pdq).to eq("hash123")
        expect(result.video_md5).to eq("hash456")
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
