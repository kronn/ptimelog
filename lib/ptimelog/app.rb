# frozen_string_literal: true

module Ptimelog
  # Wrapper for everything, mostly calling other parts
  class App
    def initialize(args)
      @config = Configuration.instance
      command = (args[0] || :show).to_sym

      @command = case command
                 when :show
                   @day = args[1]
                   Command::Show.new
                 when :upload
                   @date = args[1]
                   Command::Upload.new
                 when :edit
                   file = args[1]
                   Command::Edit.new(file)
                 else
                   raise ArgumentError, "Unsupported Command #{@command}"
                 end
    end

    def run
      @command.entries = Ptimelog::Day.new(@day).entries if @command.needs_entries?

      @command.run
    end
  end
end
