# frozen_string_literal: true

module Gpuzzletime
  # Wrapper around configuration-options and -loading
  class Configuration
    include Singleton

    CONFIGURATION_DEFAULTS = {
      base_url: 'https://time.puzzle.ch',
      rounding: 15,
      dir:      '~/.config/gpuzzletime',
      timelog:  '~/.local/share/gtimelog/timelog.txt',
    }.freeze

    def initialize
      @config = load(CONFIGURATION_DEFAULTS[:dir].join('config'))
      wrap_with_pathname(:dir)
      wrap_with_pathname(:timelog)
    end

    def load(fn)
      user_config = fn.exist? ? YAML.load_file(fn) : {}

      CONFIGURATION_DEFAULTS.merge(user_config)
    end

    private

    def wrap_pathnames(key)
      return unless @config.key?(key)
      return if @config[key].is_a? Pathname

      @config[key] = Pathname.new(@config[key]).expand_path
    end
  end
end
