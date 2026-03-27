# frozen_string_literal: true

module Ptimelog
  # Facade around several datasources, currently intended to cover the
  # timelog.txt and obsidian.md
  class DataSource
    def initialize(configuration, day)
      @configuration = configuration
      @day = day
    end

    def type
      if @configuration['timelog']
        :timelog
      elsif @configuration['obsidian']
        :obsidian
      end
    end

    def entries
      case type
      when :obsidian then { @day => backend.entries }
      when :timelog then Ptimelog::Day.new(@day).entries
      else
        []
      end
    end

    def file
      case type
      when :obsidian then backend.file
      when :timelog then backend.timelog_txt
      end
    end

    def backend
      @backend ||= case type
                   when :obsidian then Obsidian.new(@day)
                   when :timelog then Timelog.instance
                   end
    end
  end
end
