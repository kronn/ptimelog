# frozen_string_literal: true

module Ptimelog
  module Command
    # show entries of one day or all of them
    class Show < Base
      def initialize(*args)
        @durations = Hash.new(0)

        super
      end

      def needs_entries?
        true
      end

      def run
        @entries.each do |date, list|
          puts date,
               '----------'

          next if list.empty?

          list.each do |entry|
            puts entry
          end
          puts '----------',
               "Total work done: #{duration(date)} hours",
               '----------------------------',
               nil
        end
      end

      def entries=(entries)
        entries.each do |date, list|
          @entries[date] = []

          list.each do |entry|
            @durations[date] += entry.duration
            @entries[date] << entry.to_s
          end
        end
      end

      def duration(date)
        Time.at(@durations[date]).utc.strftime('%H:%M')
      end
    end
  end
end
