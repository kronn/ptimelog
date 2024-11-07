# frozen_string_literal: true

module Ptimelog
  # Facade around several datasources, currently intended to cover the
  # timelog.txt and obsidian.md
  class DataSource
    def initialize(configuration, day)
      @configuration = configuration
      @day = day
    end

    def entries
      return obsidian_entries if @configuration['obsidian']
      return timelog_entries if @configuration['timelog']

      []
    end

    def file
      return Ptimelog::Obsidian.new(@day).file if @configuration['obsidian']
      return Timelog.timelog_txt if @configuration['timelog']

      nil
    end

    private

    def obsidian_entries
      { @day => Ptimelog::Obsidian.new(@day).entries }
    end

    def timelog_entries
      Ptimelog::Day.new(@day).entries
    end
  end
end
