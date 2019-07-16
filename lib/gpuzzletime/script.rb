# frozen_string_literal: true

module Gpuzzletime
  # Wrapper around all external scripts that might be called to get more
  # information about the time-entries
  class Script
    def initialize(config_dir)
      @config_dir = config_dir
    end

    def parser(parser_name)
      @config_dir.join("parsers/#{parser_name}") # FIXME: security-hole, prevent relative paths!
                 .expand_path
    end

    def billable
      @config_dir.join('billable').expand_path
    end
  end
end
