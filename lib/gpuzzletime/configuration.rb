# frozen_string_literal: true

module Gpuzzletime
  # Wrapper around configuration-options and -loading
  class Configuration
    include Singleton

    CONFIGURATION_DEFAULTS = {
      base_url: 'https://time.puzzle.ch',
      rounding: 15,
      dir:      Pathname.new('~/.config/gpuzzletime').expand_path,
    }.freeze

    def initialize
      load(CONFIGURATION_DEFAULTS[:dir].join('config'))
    end

    def load(fn)
      user_config = fn.exist? ? YAML.load_file(fn) : {}

      CONFIGURATION_DEFAULTS.merge(user_config)
    end
  end
end
