# frozen_string_literal: true

module Ptimelog
  # Wrapper around all external scripts that might be called to get more
  # information about the time-entries
  class Script
    def initialize(config_dir)
      @config_dir = config_dir
    end

    def inferer(name)
      return NullPathname.new if name.to_s.empty?
      raise if name =~ %r{[\\/]} # prevent relavtive paths, stupidly, FIXME: really check FS

      @config_dir.join('inferers').join(name).expand_path
    end
  end
end
