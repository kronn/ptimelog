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

    def entries
      return [] unless file.exist?

      list_tokens.map { |matched_line| tokens_to_entry(matched_line) }
    end

    def add(entry)
      new_entry_doc = Commonmarker.parse("- #{entry_to_dayplanner(entry)}")
      new_entry_list = new_entry_doc.first_child
      new_item = new_entry_list.first_child

      entry_list.append_child new_item

      file.write(md_ast.to_commonmark)

      entry
    end

    def file
      obsidian_config[:daily_dir].join("#{@day}.md")
    end

    def previous_entry
      if entries.any?
        entries.last
      else
        Entry.new.tap do |entry|
          entry.date = @day
          entry.description = 'start **'
          start_time = @configuration['obsidian_start_time'] || '08:00'
          entry.start_time = start_time
          entry.finish_time = start_time
        end
      end
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

    def entry_list
      node = md_ast.drop(list_start).first
      return node if node&.type == :list

      list_node = Commonmarker.parse('- ').first_child
      node.insert_before(list_node)
      list_node
    end

    def tokenize_dayplanner(line)
      re_start = /(?<start>\d{2}:\d{2})/
      re_stop = /(?<stop>\d{2}:\d{2})/
      re_tick = /(?:(?<ticket>.*?):\s+)/
      re_desc = /(?<description>.*?)/
      re_tags = /(?:\s+--\s+(?<tags>.*)?)/

      regexp = /^#{re_start}\s*-\s*#{re_stop} #{re_tick}?#{re_desc}#{re_tags}?$/
      line.match(regexp)
    end

    def tokens_to_entry(matched_line)
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

    def dayplanner_to_entry(line)
      tokenize_dayplanner(line).then do |tokens|
        tokens_to_entry(tokens)
      end
    end

    def entry_to_dayplanner(entry)
      format(
        '%<start>s - %<finish>s %<ticket>s: %<description>s -- %<tags>s',
        start:       entry.start_time,
        finish:      entry.finish_time,
        ticket:      entry.ticket,
        description: entry.description,
        tags:        entry.tags.to_a.join(' ')
      )
    end

    def remove_tags_and_markers(line)
      line.gsub(/\s+#[a-z]+/, ' ').gsub(/\[\w+:: [^\]]+\]/, '').squeeze(' ').strip
    end

    def list_strings
      entry_list
        .filter_map(&:first_child)
        .map { |item| item.first_child.string_content }
        .map { |item| remove_tags_and_markers(item) }
        .sort
    end

    def list_tokens = list_strings.filter_map { |line| tokenize_dayplanner(line) }
  end
end
