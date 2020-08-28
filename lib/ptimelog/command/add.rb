# frozen_string_literal: true

require 'pathname'

module Ptimelog
  module Command
    # add a new entrie with the current date and time
    class Add < Base
      def initialize(task)
        super()

        @task = task
        @timelog = Ptimelog::Timelog.instance
        @new_lines = []
      end

      def needs_entries?
        false
      end

      def run
        add_empty_line if previous_entry.date == yesterday
        add_entry(Time.now.strftime('%F %R'), @task)

        save_file
      end

      private

      def add_entry(date_time, task)
        @new_lines << "#{date_time}: #{task}"
      end

      def add_empty_line
        @new_lines << ''
      end

      def save_file
        @timelog.timelog_txt.open('a') do |log|
          @new_lines.each do |line|
            log << "#{line}\n"
          end
        end
      end

      def previous_entry
        lines = @timelog.timelog_txt.readlines.last(2)
        last_line = lines.map(&:chomp).delete_if(&:empty?).last
        last_entry = @timelog.tokenize(last_line)

        Entry.from_timelog(last_entry)
      end

      def yesterday
        NamedDate.new.named_date('yesterday')
      end
    end
  end
end
