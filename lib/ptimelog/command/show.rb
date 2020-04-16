# frozen_string_literal: true

module Ptimelog
  module Command
    # show entries of one day or all of them
    class Show < Base
      def needs_entries?
        true
      end

      def run
        @entries.each do |date, list|
          puts date, '----------'
          list.each do |entry|
            puts entry
          end
          puts nil
        end
      end

      def entries=(entries)
        entries.each do |date, list|
          @entries[date] = []

          list.each do |entry|
            @entries[date] << entry.to_s
          end
        end
      end
    end
  end
end
