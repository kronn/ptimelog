# frozen_string_literal: true

module Ptimelog
  # Wrapper for everything
  class App
    def initialize(args)
      @config = Configuration.instance
      command = (args[0] || :show).to_sym

      @command = case command
                 when :show
                   @date = NamedDate.new.date(args[1])
                   Command::Show.new
                 when :upload
                   @date = NamedDate.new.date(args[1])
                   Command::Upload.new
                 when :edit
                   file = args[1]
                   Command::Edit.new(file)
                 else
                   raise ArgumentError, "Unsupported Command #{@command}"
                 end
    end

    def run
      @command.entries = entries if @command.needs_entries?

      @command.run
    end

    private

    def timelog
      Timelog.load
    end

    def entries
      timelog.each_with_object({}) do |(date, lines), entries|
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

        entries
      end
    end
  end
end
