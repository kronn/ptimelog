# frozen_string_literal: true

require 'commonmarker'
require 'pathname'

module Ptimelog
  # Extract entries from a Obsidian+DayPlanner list
  class Obsidian
    def initialize(day)
      @day = day
      @configuration = Ptimelog::Configuration.instance
    end

    # Inform about potentially malformed Markdown
    class HeadingNotFound < Ptimelog::Error
      def initialize(config)
        super(<<~MSG)
          Could not find level-#{config[:level]} Heading '#{config[:title]}'

          Please check that the heading is there and valid markdown.
          I often have typos right before the heading if I type in the wrong window, maybe you do, too?
        MSG
      end
    end

    def entries # rubocop:disable Metrics/AbcSize
      list_tokens.map do |matched_line|
        entry = Ptimelog::Entry.new
        entry.date        = @day
        entry.ticket      = matched_line[:ticket]
        entry.description = matched_line[:description]
        entry.start_time  = matched_line[:start]
        entry.finish_time = matched_line[:stop]
        entry.tags        = matched_line[:tags]

        entry.infer_ptime_settings

        entry
      end
    end

    def file
      obsidian_config[:daily_dir].join("#{@day}.md")
    end

    private

    def heading_config
      {
        level: @configuration['dayplanner_heading_level'],
        title: @configuration['dayplanner_heading_title'],
      }
    end

    def obsidian_config
      {
        daily_dir: @configuration['obsidian_daily_dir'],
      }
    end

    def md_ast
      @md_ast ||= Commonmarker.parse(file.read)
    end

    def heading_idx
      index = md_ast.find_index do |node|
        node.type == :heading &&
          node.header_level == heading_config[:level] &&
          node.first_child.string_content == heading_config[:title]
      end
      raise HeadingNotFound, heading_config if index.nil?

      index
    end

    def list_start = heading_idx + 1

    def entry_list = md_ast.drop(list_start).first

    def tokenize_dayplanner(line)
      re_start = /(?<start>\d{2}:\d{2})/
      re_stop = /(?<stop>\d{2}:\d{2})/
      re_tick = /(?:(?<ticket>.*?): )/
      re_desc = /(?<description>.*?)/
      re_tags = /(?: -- (?<tags>.*)?)/

      regexp = /^#{re_start} - #{re_stop} #{re_tick}?#{re_desc}#{re_tags}?$/
      line.match(regexp)
    end

    def remove_tags_and_markers(line)
      line.gsub(/\s+#[a-z]+/, ' ').gsub(/\[\w+:: [^\]]+\]/, '').squeeze(' ').strip
    end

    def list_strings
      entry_list
        .map(&:first_child)
        .compact
        .map { |item| item.first_child.string_content }
        .map { |item| remove_tags_and_markers(item) }
        .sort
    end

    def list_tokens = list_strings.map { |line| tokenize_dayplanner(line) }.compact
  end
end
