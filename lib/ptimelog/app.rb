# frozen_string_literal: true

module Ptimelog
  # Wrapper for everything, dispatching to a command
  class App
    def initialize(args)
      @config = Configuration.instance
      command = (args[0] || 'show')

      constant_name = command.to_s[0].upcase + command[1..-1].downcase
      command_class = Command.const_get(constant_name.to_sym)
      raise ArgumentError, "Unsupported Command '#{command}'" if command_class.nil?

      @command = command_class.new(args[1]) # e.g. Ptimelog::Command::Show.new('today')
    end

    def run
      @command.run
    end
  end
end
