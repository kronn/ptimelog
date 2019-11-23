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
      return false if name.nil?
      raise if name =~ %r{[\\/]} # prevent relavtive paths, stupidly, FIXME: really check FS

      @config_dir.join('inferers').join(name).expand_path
    end

    # rubocop:disable Style/GlobalVars
    def deprecate(script_fn)
      warn deprecate_header(script_fn)

      return unless $deprecation_warning_rendered.nil?

      warn deprecate_message
      $deprecation_warning_rendered = true
    end
    # rubocop:enable Style/GlobalVars

    def deprecate_message
      <<~MESSAGE
        Please move the parser- and billable-scripts to an inferer-script.
        Support for the previous scripts in parsers/* and billable will
        be dropped in 0.7.

      MESSAGE
    end

    def deprecate_header(script_fn)
      warn "DEPRECATION NOTICE: #{script_fn} is deprecated"
    end
  end
end
