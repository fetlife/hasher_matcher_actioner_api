# frozen_string_literal: true

require "bundler/setup"
require "hasher_matcher_actioner_api"
require "webmock/rspec"
require "vcr"
require_relative "support/shared_stubs"
require_relative "support/test_constants"

# https://dev.to/kabisasoftware/matching-multipart-request-bodies-with-vcr-2mf4
class VCRMultipartBodyMatcher
  MULTIPART_HEADER_MATCHER = %r{^multipart/form-data; boundary=(.+)$}

  def call(request_1, request_2)
    normalized_multipart_body(request_1) == normalized_multipart_body(request_2)
  end

  private

  def normalized_multipart_body(request)
    content_type = (request.headers['Content-Type'] || []).first.to_s

    return request.body unless multipart_request?(content_type)

    boundary = MULTIPART_HEADER_MATCHER.match(content_type)[1]
    request.body.gsub(boundary, '----RubyFormBoundaryTsqIBL0iujC5POpr')
  end

  def multipart_request?(content_type)
    return false if content_type.empty?

    MULTIPART_HEADER_MATCHER.match?(content_type)
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri, :body]
  }

  # Register the custom multipart body matcher
  config.register_request_matcher :body do |request1, request2|
    VCRMultipartBodyMatcher.new.call(request1, request2)
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.warnings = true

  config.order = :random
  Kernel.srand config.seed
end
