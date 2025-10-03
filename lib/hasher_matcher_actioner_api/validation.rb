# frozen_string_literal: true

module HasherMatcherActionerApi
  module Validation
    def validate_content_type!(content_type)
      if content_type && !Configuration::CONTENT_TYPES.include?(content_type)
        raise ValidationError, "content_type must be one of: #{Configuration::CONTENT_TYPES.join(", ")}, received: #{content_type}"
      end
    end

    def validate_signal_types!(signal_types)
      if signal_types&.any? { |signal_type| !Configuration::SIGNAL_TYPES.include?(signal_type) }
        raise ValidationError, "signal types must be one of: #{Configuration::SIGNAL_TYPES.join(", ")}, received: #{signal_types.join(", ")}"
      end
    end
  end
end
