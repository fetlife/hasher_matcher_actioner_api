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

  describe "#add_url_to_bank" do
    let(:test_bank_name) { "TEST_BANK" }
    let(:test_url) { "https://raw.githubusercontent.com/fetlife/hasher_matcher_actioner_api/main/spec/fixtures/image-in-hash-db.jpg" }

    it "adds content to bank successfully", :vcr do
      result = client.add_url_to_bank(
        bank_name: test_bank_name,
        url: test_url,
        content_type: "photo"
      )
      expect(result).to be_a(HasherMatcherActionerApi::Banks::BankContentResult)
      expect(result.id).to be_a(Integer)
      expect(result.signals.pdq).to eq(HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH)
    end

    it "adds content with metadata", :vcr do
      metadata = {
        content_id: "test-content-456",
        content_uri: "https://example.com/original-image.jpg",
        json: { source: "url_test", priority: "medium" }
      }

      result = client.add_url_to_bank(
        bank_name: test_bank_name,
        url: test_url,
        content_type: "photo",
        metadata: metadata
      )
      expect(result).to be_a(HasherMatcherActionerApi::Banks::BankContentResult)
      expect(result.id).to be_a(Integer)
      expect(result.signals).to be_a(HasherMatcherActionerApi::Banks::BankContentResult::Signals)
      expect(result.signals.pdq).to eq(HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH)
    end

    it "works without content_type", :vcr do
      result = client.add_url_to_bank(
        bank_name: test_bank_name,
        url: test_url
      )
      expect(result).to be_a(HasherMatcherActionerApi::Banks::BankContentResult)
      expect(result.id).to be_a(Integer)
      expect(result.signals).to be_a(HasherMatcherActionerApi::Banks::BankContentResult::Signals)
      expect(result.signals.pdq).to eq(HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH)
    end

    it "raises error for invalid content_type", :vcr do
      expect {
        client.add_url_to_bank(
          bank_name: test_bank_name,
          url: test_url,
          content_type: "invalid_type"
        )
      }.to raise_error(HasherMatcherActionerApi::ValidationError)
    end

    it "raises error for non-existent bank", :vcr do
      expect {
        client.add_url_to_bank(
          bank_name: "NON_EXISTENT_BANK",
          url: test_url,
          content_type: "photo"
        )
      }.to raise_error(HasherMatcherActionerApi::NotFoundError)
    end
  end

  describe "#add_file_to_bank" do
    let(:test_bank_name) { "TEST_BANK" }
    let(:test_file) { File.open("spec/fixtures/image-in-hash-db.jpg", "rb") }

    after do
      test_file&.close
    end

    it "adds content to bank successfully", :vcr do
      result = client.add_file_to_bank(
        bank_name: test_bank_name,
        file: test_file,
        content_type: "photo"
      )
      expect(result).to be_a(HasherMatcherActionerApi::Banks::BankContentResult)
      expect(result.id).to be_a(Integer)
      expect(result.signals).to be_a(HasherMatcherActionerApi::Banks::BankContentResult::Signals)
      expect(result.signals.pdq).to eq(HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH)
    end

    it "adds content with metadata", :vcr do
      metadata = {
        content_id: "test-content-123",
        content_uri: "https://example.com/original-image.jpg",
        json: { source: "test", priority: "high" }
      }

      result = client.add_file_to_bank(
        bank_name: test_bank_name,
        file: test_file,
        content_type: "photo",
        metadata: metadata
      )
      expect(result).to be_a(HasherMatcherActionerApi::Banks::BankContentResult)
      expect(result.id).to be_a(Integer)
      expect(result.signals).to be_a(HasherMatcherActionerApi::Banks::BankContentResult::Signals)
      expect(result.signals.pdq).to eq(HasherMatcherActionerApi::TestConstants::IMAGE_IN_DB_PDQ_HASH)
    end

    it "raises error for missing content_type" do
      expect {
        client.add_file_to_bank(
          bank_name: test_bank_name,
          file: test_file
        )
      }.to raise_error(ArgumentError, /missing keyword: :content_type/)
    end

    it "raises error for invalid content_type", :vcr do
      expect {
        client.add_file_to_bank(
          bank_name: test_bank_name,
          file: test_file,
          content_type: "invalid_type"
        )
      }.to raise_error(HasherMatcherActionerApi::ValidationError)
    end

    it "raises error for non-IO object", :vcr do
      expect {
        client.add_file_to_bank(
          bank_name: test_bank_name,
          file: "not a file",
          content_type: "photo"
        )
      }.to raise_error(HasherMatcherActionerApi::ValidationError)
    end

    it "raises error for non-existent bank", :vcr do
      expect {
        client.add_file_to_bank(
          bank_name: "NON_EXISTENT_BANK",
          file: test_file,
          content_type: "photo"
        )
      }.to raise_error(HasherMatcherActionerApi::NotFoundError)
    end
  end
end
