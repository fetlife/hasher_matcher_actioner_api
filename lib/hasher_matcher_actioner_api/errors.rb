# frozen_string_literal: true

module HasherMatcherActionerApi
  class Error < StandardError; end

  # HTTP Errors
  class ConnectionError < Error; end

  # Usage Errors
  class ArgumentError < Error; end

  # API Errors
  class AuthenticationError < Error; end

  class NotFoundError < Error; end

  class PermissionError < Error; end

  class ServerError < Error; end

  class ValidationError < Error; end

  class ApiNotConfiguredError < Error; end
end
