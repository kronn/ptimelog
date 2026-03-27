# frozen_string_literal: true

require 'pathname'

module Ptimelog
  module Command
    # add a new entrie with the current date and time
    class Add < CmdParse::Command
      def initialize
        super('add', takes_commands: false)

        @data_source = DataSource.new(
          Configuration.instance,
          NamedDate.new.named_date('today')
        )
        @timelog = Ptimelog::Timelog.instance
        options.on('--debug', 'Show debugging output') { @debug = true }
      end

      def execute(task_line)
        start = backend.previous_entry.finish_time
        finish, task = parse_task(task_line)
        ticket, desc = task.split(':', 2)

        entry = create_entry(start, finish, ticket, desc)
        debug(entry.to_s)

        backend.add(entry)
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
                         .strftime('%R')

        [formatted_time, matches[:task]]
      end

      def create_entry(start, finish, ticket, desc)
        Entry.new.tap do |e|
          e.date = Date.today
          e.start_time = start
          e.finish_time = finish
          e.ticket = ticket
          e.description = desc
        end
      end

      def backend
        @data_source.backend
      end

      def debug(msg)
        return unless @debug

        warn msg
      end
    end
  end
end
