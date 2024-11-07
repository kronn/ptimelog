# frozen_string_literal: true

require 'pathname'

module Ptimelog
  module Command
    # add a new entrie with the current date and time
    class Add < CmdParse::Command
      def initialize
        super('add', takes_commands: false)

        @timelog = Ptimelog::Timelog.instance
        @new_lines = []
      end

      def execute(task)
        abort('only timelog is supported for this action') unless Ptimelog::Configuration.instance['timelog']

        add_empty_line if @timelog.previous_entry.date == yesterday
        add_entry(*parse_task(task))

        save_file
      end

      private

      def parse_task(line)
        matches = line.match('(?<time>\d{1,2}:\d{2} )?(?<offset>[+-]\d+ )?(?<task>.*)')
        formatted_time = if matches[:time]
                           Time.parse(matches[:time])
                         else
                           Time.now
                         end
                         .localtime
                         .then { |time| time + (matches[:offset].to_i * 60) }
                         .strftime('%F %R')

        [formatted_time, matches[:task]]
      end

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

      def yesterday
        NamedDate.new.named_date('yesterday')
      end
    end
  end
end
