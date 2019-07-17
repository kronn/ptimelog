# frozen_string_literal: true

require 'date'
require 'erb'
require 'pathname'

module Gpuzzletime
  # Wrapper for everything
  class App
    CONFIGURATION_DEFAULTS = {
      base_url: 'https://time.puzzle.ch',
      rounding: 15,
      dir:      Pathname.new('~/.config/gpuzzletime').expand_path,
    }.freeze

    def initialize(args)
      @config = load_config(CONFIGURATION_DEFAULTS[:dir].join('config'))
      command = (args[0] || :show).to_sym

      @date = named_dates(args[1] || 'last') || :all
      @command = case command
                 when :show
                   Gpuzzletime::Command::Show.new(@config)
                 when :upload
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

    def load_config(config_fn)
      user_config = config_fn.exist? ? YAML.load_file(config_fn) : {}

      CONFIGURATION_DEFAULTS.merge(user_config)
    end

    def entries
      @entries ||= {}
    end

    def timelog
      Gpuzzletime::Timelog.load
    end

    def fill_entries
      timelog.each do |date, lines|
        # this is mixing preparation, assembly and output, but gets the job done
        next unless date                           # guard against the machine
        next unless @date == :all || @date == date # limit to one day if passed

        entries[date] = []
        start = nil # at the start of the day, we have no previous end

        lines.each do |line|
          entry = Entry.from_timelog(@config, line)
          entry.start_time = start

          entries[date] << entry if entry.valid?

          start = entry.finish_time # store previous ending for nice display of next entry
        end
      end
    end

    def named_dates(date)
      case date
      when 'yesterday'        then Date.today.prev_day.to_s
      when 'today'            then Date.today.to_s
      when 'last'             then timelog.to_h.keys.compact.sort[-2] || Date.today.prev_day.to_s
      when /\d{4}(-\d{2}){2}/ then date
      end
    end
  end
end
