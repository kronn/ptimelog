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
            @entries[date] << [
              entry.start_time, '-', entry.finish_time,
              [
                entry.ticket,
                entry.description,
                entry.tags,
                entry.account,
                (entry.billable? ? '$' : nil),
              ].compact.join(' ∴ '),
            ].compact.join(' ')
          end
        end
      end
    end
  end
end
