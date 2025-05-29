# frozen_string_literal: true

module HasherMatcherActionerApi
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class NotFoundError < Error; end
  class PermissionError < Error; end
  class ServerError < Error; end
  class ValidationError < Error; end
  class ApiNotConfiguredError < StandardError; end
  class ArgumentError < StandardError; end
end 