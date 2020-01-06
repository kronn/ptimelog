# frozen_string_literal: true

module Ptimelog
  # Allow to add some (hopefully) helpful deprecation warning
  module DeprecationWarning
    def self.included(base)
      base.send :extend, ClassMethods
    end

    # Keep track of wether the deprecation have been shown already or not
    module ClassMethods
      def deprecation_warning_rendered?
        @deprecation_warning_rendered == true
      end

      def reset_deprecation_warning!
        @deprecation_warning_rendered = false
      end

      def deprecation_warning_rendered!
        @deprecation_warning_rendered = true
      end
    end

    def deprecate(*args)
      warn deprecate_header(*args)

      return if self.class.deprecation_warning_rendered?

      warn deprecate_message(*args)
      self.class.deprecation_warning_rendered!
    end

    def deprecate_header(_)
      raise <<~MESSAGE
        deprecate_header(args) not implemented

        Please define a header/short-info for the deprecation, rendered every
        time the deprecation is hit.
      MESSAGE
    end

    def deprecate_message(_)
      raise <<~MESSAGE
        deprecate_message(args) not implemented

        Please define a message () for the deprecation, rendered only the first
        time the deprecation is hit.
      MESSAGE
    end
  end
end
