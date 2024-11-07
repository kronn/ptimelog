# frozen_string_literal: true

require 'singleton'
require 'pathname'
require 'yaml'

module Ptimelog
  # Wrapper around configuration-options and -loading
  class Configuration
    include Singleton

    CONFIGURATION_DEFAULTS = {
      'base_url'                 => 'https://time.puzzle.ch',
      'rounding'                 => 15,
      'dir'                      => '~/.config/ptimelog',
      'timelog'                  => true,
      'timelog_txt'              => '~/.local/share/gtimelog/timelog.txt',
      'obsidian'                 => false,
      'dayplanner_heading_level' => 1,
      'dayplanner_heading_title' => 'Dayplanner',
      'obsidian_daily_dir'       => '~/Obsidian/Vault/daily',
    }.freeze

    def initialize
      reset
    end

    def reset
      @config = load_config(
        Pathname.new(CONFIGURATION_DEFAULTS['dir'])
                .expand_path
                .join('config')
      )
      wrap_with_pathname('dir')

      wrap_with_pathname('timelog_txt') if self['timelog']
      wrap_with_pathname('obsidian_daily_dir') if self['obsidian']
    end

    def load_config(fn)
      user_config = fn.exist? ? YAML.load_file(fn) : {}

      CONFIGURATION_DEFAULTS.merge(user_config)
    end

    def [](key)
      @config[key.to_s]
    end

    def []=(key, value)
      @config[key.to_s] = value

      wrap_with_pathname(key.to_s) if %w[obsidian_daily_dir dir timelog_txt].include?(key.to_s)
    end

    private

    def wrap_with_pathname(key)
      return unless @config.key?(key)
      return unless @config[key].is_a? String
      return @config[key] if @config[key].is_a? Pathname

      @config[key] = Pathname.new(@config[key]).expand_path
    end
  end
end
