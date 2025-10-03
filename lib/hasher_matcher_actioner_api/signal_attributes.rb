# frozen_string_literal: true

module HasherMatcherActionerApi
  module SignalAttributes
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def add_signal_attributes(type_class = HasherMatcherActionerApi::Types::String.optional)
        HasherMatcherActionerApi::Configuration::SIGNAL_TYPES.each do |type|
          attribute? type, type_class
        end
      end
    end
  end
end
