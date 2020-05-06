# frozen_string_literal: true

module Ptimelog
  module Command
    # Output the Version-Number
    class Version < Base
      def initialize(_arg)
        super(nil)
      end

      def run
        puts Ptimelog::VERSION
      end
    end
  end
end
