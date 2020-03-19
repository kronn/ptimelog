# typed: true
# frozen_string_literal: true

module Ptimelog
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

    def inferer(name)
      return NullPathname.new if name.to_s.empty?
      raise if name =~ %r{[\\/]} # prevent relavtive paths, stupidly, FIXME: really check FS

      @config_dir.join('inferers').join(name).expand_path
    end

    include DeprecationWarning

    def deprecate_message(_)
      <<~MESSAGE
        Please move the parser- and billable-scripts to an inferer-script.
        Support for the previous scripts in parsers/* and billable will
        be dropped in 0.7.

      MESSAGE
    end

    def deprecate_header(script_fn)
      "DEPRECATION NOTICE: #{script_fn} is deprecated"
    end
  end
end
