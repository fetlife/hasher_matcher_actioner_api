# frozen_string_literal: true

require "spec_helper"

RSpec.describe HasherMatcherActionerApi::Client do
  let(:client) { described_class.new(base_url: "http://localhost:5000", max_retries: 0) }

  describe "#raw_lookup" do
    let(:signal) { "test_signal" }
    let(:signal_type) { "pdq" }

    context "without distance" do
      before do
        stub_successful_response(
          :get,
          "/m/raw_lookup",
          query: {signal: signal, signal_type: signal_type, include_distance: false},
          body: {matches: [1, 2, 3]}
        )
      end

      it "returns matches result" do
        result = client.raw_lookup(signal, signal_type: signal_type)
        expect(result.matches).to eq([1, 2, 3])
      end
    end

    context "with distance" do
      before do
        stub_successful_response(
          :get,
          "/m/raw_lookup",
          query: {signal: signal, signal_type: signal_type, include_distance: true},
          body: {matches: [{bank_content_id: 1, distance: 5}, {bank_content_id: 2, distance: 10}]}
        )
      end

      it "returns matches result with distance" do
        result = client.raw_lookup(signal, signal_type: signal_type, include_distance: true)
        expect(result.matches.map(&:bank_content_id)).to eq([1, 2])
        expect(result.matches.map(&:distance)).to eq([5, 10])
      end
    end

    context "with invalid signal type" do
      it "raises error" do
        expect {
          client.raw_lookup(signal, signal_type: "invalid_type")
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end
    end
  end

  describe "#lookup_url" do
    let(:url) { "https://example.com/image.jpg" }
    let(:valid_content_type) { "photo" }
    let(:valid_signal_types) { ["pdq", "video_md5"] }

    context "with valid parameters" do
      before do
        stub_successful_response(
          :get,
          "/m/lookup",
          query: {url: url},
          body: {
            pdq: {
              "bank1" => [{bank_content_id: 1, distance: 5}],
              "bank2" => [{bank_content_id: 2, distance: 10}]
            },
            video_md5: {
              "bank1" => [{bank_content_id: 3, distance: 15}]
            }
          }
        )
      end

      it "returns normalized matches" do
        result = client.lookup_url(url)
        expect(result).to contain_exactly(
          have_attributes(signal_type: "pdq", bank_name: "bank1", bank_content_id: 1, distance: 5),
          have_attributes(signal_type: "pdq", bank_name: "bank2", bank_content_id: 2, distance: 10),
          have_attributes(signal_type: "video_md5", bank_name: "bank1", bank_content_id: 3, distance: 15)
        )
      end

      context "with content type" do
        before do
          stub_successful_response(
            :get,
            "/m/lookup",
            query: {url: url, content_type: valid_content_type},
            body: {
              pdq: {
                "bank1" => [{bank_content_id: 1, distance: 5}]
              }
            }
          )
        end

        it "returns normalized matches with content type" do
          result = client.lookup_url(url, content_type: valid_content_type)
          expect(result).to contain_exactly(
            have_attributes(signal_type: "pdq", bank_name: "bank1", bank_content_id: 1, distance: 5)
          )
        end
      end

      context "with signal types" do
        before do
          stub_successful_response(
            :get,
            "/m/lookup",
            query: {url: url, types: valid_signal_types.join(",")},
            body: {
              pdq: {
                "bank1" => [{bank_content_id: 1, distance: 5}]
              },
              video_md5: {
                "bank1" => [{bank_content_id: 2, distance: 10}]
              }
            }
          )
        end

        it "returns normalized matches with specified signal types" do
          result = client.lookup_url(url, signal_types: valid_signal_types)
          expect(result).to contain_exactly(
            have_attributes(signal_type: "pdq", bank_name: "bank1", bank_content_id: 1, distance: 5),
            have_attributes(signal_type: "video_md5", bank_name: "bank1", bank_content_id: 2, distance: 10)
          )
        end
      end
    end

    context "with invalid parameters" do
      it "raises error for invalid content type" do
        expect {
          client.lookup_url(url, content_type: "invalid_type")
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end

      it "raises error for invalid signal types" do
        expect {
          client.lookup_url(url, signal_types: ["invalid_type"])
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end
    end
  end

  describe "#lookup_file" do
    let(:file) { StringIO.new("test content") }
    let(:valid_content_type) { "photo" }

    context "with valid parameters" do
      before do
        stub_successful_post(
          "/m/lookup",
          body: {
            pdq: {
              "bank1" => [{bank_content_id: 1, distance: 5}],
              "bank2" => [{bank_content_id: 2, distance: 10}]
            }
          }
        )
      end

      it "returns normalized matches" do
        result = client.lookup_file(file, content_type: valid_content_type)
        expect(result).to contain_exactly(
          have_attributes(signal_type: "pdq", bank_name: "bank1", bank_content_id: 1, distance: 5),
          have_attributes(signal_type: "pdq", bank_name: "bank2", bank_content_id: 2, distance: 10)
        )
      end
    end

    context "with invalid parameters" do
      it "raises error for missing content type" do
        expect {
          client.lookup_file(file, content_type: nil)
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end

      it "raises error for invalid content type" do
        expect {
          client.lookup_file(file, content_type: "invalid_type")
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end

      it "raises error for non-IO object" do
        expect {
          client.lookup_file("not a file", content_type: valid_content_type)
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end
    end
  end
end
