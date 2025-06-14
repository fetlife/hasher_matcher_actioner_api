# frozen_string_literal: true

module HasherMatcherActionerApi
  class Error < StandardError; end

  # HTTP Errors
  class ConnectionError < Error; end

  # Usage Errors
  class ClientArgumentError < Error; end

  # API Errors
  class AuthenticationError < Error; end

  class NotFoundError < Error; end

  class ConfigurationError < Error; end

  class ResourceAlreadyExistsError < Error; end

  class ServerError < Error; end

  class ValidationError < Error; end

  class ApiNotConfiguredError < Error; end
end
