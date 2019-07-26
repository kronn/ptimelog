# frozen_string_literal: true

require 'date'
require 'erb'
require 'pathname'

module Gpuzzletime
  # Wrapper for everything
  class App
    def initialize(args)
      @config = Configuration.instance
      command = (args[0] || :show).to_sym

      @command = case command
                 when :show
                   @date = NamedDate.new.date(args[1])
                   Gpuzzletime::Command::Show.new(@config)
                 when :upload
                   @date = NamedDate.new.date(args[1])
                   Gpuzzletime::Command::Upload.new(@config)
                 when :edit
                   Gpuzzletime::Command::Edit.new(@config, args[1])
                 else
                   raise ArgumentError, "Unsupported Command #{@command}"
                 end
    end

    def run
      if @command.needs_entries?
        fill_entries
        @command.entries = entries
      end

      @command.run
    end

    private

    def entries
      @entries ||= {}
    end

    def timelog
      Timelog.load
    end

    def fill_entries
      timelog.each do |date, lines|
        next unless date                           # guard against the machine
        next unless @date == :all || @date == date # limit to one day if passed

        entries[date] = []
        start = nil # at the start of the day, we have no previous end

        lines.each do |line|
          entry = Entry.from_timelog(line)
          entry.start_time = start

          entries[date] << entry if entry.valid?

          start = entry.finish_time # store previous ending for nice display of next entry
        end
      end
    end
  end
end
