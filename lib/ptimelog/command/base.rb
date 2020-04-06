# frozen_string_literal: true

module Ptimelog
  module Command
    # Foundation and common API for all commands
    class Base
      def initialize(day = nil)
        @config = Configuration.instance

        return unless needs_entries?

        @entries = Ptimelog::Day.new(day).entries
      end

      def needs_entries?
        false
      end

      def run
        raise 'Implement a run-method for your command'
      end

      def entries=(_values)
        raise 'Implement a entries-writer-method for your command' if needs_entries?
      end
    end
  end
end
