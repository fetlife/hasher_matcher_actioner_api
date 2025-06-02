# frozen_string_literal: true

module SharedStubs
  def stub_response(method, path, body:, query: {}, status: 200, headers: {"Content-Type" => "application/json"})
    stub_request(method, "http://localhost:5000#{path}")
      .with(query: query)
      .to_return(
        status: status,
        body: body.to_json,
        headers: headers
      )
  end

  def stub_successful_response(method, path, body:, query: {})
    stub_response(method, path, body: body, query: query, status: 200, headers: {"Content-Type" => "application/json"})
  end

  def stub_successful_post(path, body:)
    stub_request(:post, "http://localhost:5000#{path}")
      .to_return(
        status: 200,
        body: body.to_json,
        headers: {"Content-Type" => "application/json"}
      )
  end
end

RSpec.configure do |config|
  config.include SharedStubs
end
