# frozen_string_literal: true

require "spec_helper"

RSpec.describe HasherMatcherActionerApi::Client do
  let(:client) { described_class.new(base_url: "http://127.0.0.1:5050", max_retries: 0) }

  describe "#raw_lookup" do
    let(:signal_type) { "pdq" }

    context "with a signal found in the database" do
      let(:signal) { HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH }

      context "without distance" do
        it "returns matches result", :vcr do
          result = client.raw_lookup(signal, signal_type: signal_type)
          expect(result.matches).not_to be_empty
        end
      end

      context "with distance" do
        it "returns matches result with distance", :vcr do
          result = client.raw_lookup(signal, signal_type: signal_type, include_distance: true)
          expect(result.matches).not_to be_empty
          expect(result.matches.first).to respond_to(:bank_content_id)
          expect(result.matches.first).to respond_to(:distance)
        end
      end
    end

    context "with a signal with a partial match found in the database" do
      let(:signal) { HasherMatcherActionerApi::TestConstants::IMAGE_EDIT_IN_DB_PDQ_HASH }

      it "returns matches result", :vcr do
        result = client.raw_lookup(signal, signal_type: signal_type)
        expect(result.matches).not_to be_empty
      end
    end

    context "with a signal not found in the database" do
      let(:signal) { HasherMatcherActionerApi::TestConstants::IMAGE_NOT_IN_DB_PDQ_HASH }

      it "returns empty matches", :vcr do
        result = client.raw_lookup(signal, signal_type: signal_type)
        expect(result.matches).to be_empty
      end
    end

    context "with invalid signal type" do
      let(:signal) { HasherMatcherActionerApi::TestConstants::IMAGE_NOT_IN_DB_PDQ_HASH }

      it "raises error" do
        expect {
          client.raw_lookup(signal, signal_type: "invalid_type")
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end
    end
  end

  describe "#lookup_url" do
    let(:url) { "https://raw.githubusercontent.com/fetlife/hasher_matcher_actioner_api/main/spec/fixtures/image-in-hash-db.jpg" }
    let(:valid_content_type) { "photo" }
    let(:valid_signal_types) { ["pdq"] }

    context "with valid parameters" do
      context "with a signal found in the database" do
        it "returns normalized matches", :vcr do
          result = client.lookup_url(url)
          expect(result).not_to be_empty

          match = result.first
          expect(match.signal_type).to eq("pdq")
          expect(match.bank_name).to eq("BANK")
          expect(match.bank_content_id).to eq(4)
          expect(match.distance).to eq(0)
        end

        context "with content type" do
          it "returns normalized matches with content type", :vcr do
            result = client.lookup_url(url, content_type: valid_content_type)
            expect(result).not_to be_empty
            expect(result.first).to respond_to(:signal_type)
            expect(result.first).to respond_to(:bank_name)
            expect(result.first).to respond_to(:bank_content_id)
            expect(result.first).to respond_to(:distance)
          end
        end

        context "with signal types" do
          it "returns normalized matches with specified signal types", :vcr do
            result = client.lookup_url(url, signal_types: valid_signal_types)
            expect(result).not_to be_empty
            expect(result.first).to respond_to(:signal_type)
            expect(result.first).to respond_to(:bank_name)
            expect(result.first).to respond_to(:bank_content_id)
            expect(result.first).to respond_to(:distance)
          end
        end
      end

      context "with a signal with a partial match found in the database" do
        let(:url) { "https://raw.githubusercontent.com/fetlife/hasher_matcher_actioner_api/main/spec/fixtures/edit-of-image-in-hash-db.jpg" }
        it "returns matches result", :vcr do
          result = client.lookup_url(url)
          expect(result).not_to be_empty

          match = result.first
          expect(match.signal_type).to eq("pdq")
          expect(match.bank_name).to eq("BANK")
          expect(match.bank_content_id).to eq(4)
          expect(match.distance).to eq(26)
        end
      end

      context "with a signal not found in the database" do
        let(:url) { "https://raw.githubusercontent.com/fetlife/hasher_matcher_actioner_api/main/spec/fixtures/image-not-in-hash-db.jpg" }

        it "returns empty matches", :vcr do
          result = client.lookup_url(url)
          expect(result).to be_empty
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
    let(:file) { File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "image-in-hash-db.jpg")) }
    let(:valid_content_type) { "photo" }

    context "with valid parameters" do
      context "with a signal found in the database" do
        it "returns normalized matches", vcr: {match_requests_on: [:method, :uri]} do
          result = client.lookup_file(file, content_type: valid_content_type)
          expect(result).not_to be_empty

          match = result.first
          expect(match.signal_type).to eq("pdq")
          expect(match.bank_name).to eq("BANK")
          expect(match.bank_content_id).to eq(4)
          expect(match.distance).to eq(0)
        end
      end

      context "with a signal with a partial match found in the database" do
        let(:file) { File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "edit-of-image-in-hash-db.jpg")) }

        it "returns matches result", vcr: {match_requests_on: [:method, :uri]} do
          result = client.lookup_file(file, content_type: valid_content_type)
          expect(result).not_to be_empty

          match = result.first
          expect(match.signal_type).to eq("pdq")
          expect(match.bank_name).to eq("BANK")
          expect(match.bank_content_id).to eq(4)
          expect(match.distance).to eq(26)
        end
      end

      context "with a signal not found in the database" do
        let(:file) { File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "image-not-in-hash-db.jpg")) }

        it "returns empty matches", vcr: {match_requests_on: [:method, :uri]} do
          result = client.lookup_file(file, content_type: valid_content_type)
          expect(result).to be_empty
        end
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

  describe "#lookup_signal" do
    let(:signal) { HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH }
    let(:signal_type) { "pdq" }

    context "with valid parameters" do
      context "with a signal found in the database" do
        it "returns normalized matches", :vcr do
          result = client.lookup_signal(signal, signal_type)
          expect(result).not_to be_empty

          # Find the match from BANK bank
          bank_match = result.find { |match| match.bank_name == "BANK" }
          expect(bank_match).not_to be_nil
          expect(bank_match.signal_type).to eq("pdq")
          expect(bank_match.bank_content_id).to eq(4)
          expect(bank_match.distance).to eq(0)
        end
      end

      context "with a signal with a partial match found in the database" do
        let(:signal) { HasherMatcherActionerApi::TestConstants::IMAGE_EDIT_IN_DB_PDQ_HASH }

        it "returns matches result", :vcr do
          result = client.lookup_signal(signal, signal_type)
          expect(result).not_to be_empty

          # Find the match from BANK bank
          bank_match = result.find { |match| match.bank_name == "BANK" }
          expect(bank_match).not_to be_nil
          expect(bank_match.signal_type).to eq("pdq")
          expect(bank_match.bank_content_id).to eq(4)
          expect(bank_match.distance).to eq(26)
        end
      end

      context "with a signal not found in the database" do
        let(:signal) { HasherMatcherActionerApi::TestConstants::IMAGE_NOT_IN_DB_PDQ_HASH }

        it "returns empty matches", :vcr do
          result = client.lookup_signal(signal, signal_type)
          expect(result).to be_empty
        end
      end
    end

    context "with invalid parameters" do
      it "raises error for invalid signal type" do
        expect {
          client.lookup_signal(signal, "invalid_type")
        }.to raise_error(HasherMatcherActionerApi::ValidationError)
      end
    end
  end
end
