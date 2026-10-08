# frozen_string_literal: true

require 'date'
require 'time'
require 'yaml'

module Ptimelog
  # Extract entries from the time-sessions Operon tracks on its tasks
  class Operon
    # Operon documents its own task-syntax as examples, and the archive is history
    SKIP_PATHS = ['Operon/Docs', 'archive'].freeze

    FIELD_RE = /\{\{(\w+)::\s*(.*?)\}\}/
    TASK_RE  = /^\s*-\s\[( |x|X)\]\s/
    RANGE_RE = %r{
      \A(?<start>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2})?)/
      (?<stop>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2})?)\z
    }x

    def initialize(day)
      @day = day
      @configuration = Ptimelog::Configuration.instance
    end

    # A session belongs to the day it started on. Plans and running timers are no time yet
    def entries
      markdown_files.flat_map { |file| entries_of(file) }
                    .sort_by(&:start_time)
    end

    # An entry can come from any note of the vault, so there is no one file to point at
    def file = NullPathname.new

    private

    def vault = @configuration['obsidian_vault']

    def markdown_files
      Dir.glob(vault.join('**/*.md')).reject { |fn| ignored?(fn) }
    end

    def ignored?(fn)
      relative = fn.delete_prefix("#{vault}/")

      SKIP_PATHS.any? { |path| relative.start_with?("#{path}/") }
    end

    def entries_of(fn)
      frontmatter, body = split_frontmatter(File.read(fn, encoding: 'UTF-8'))

      file_task_entries(frontmatter, fn) + inline_entries(body)
    end

    def file_task_entries(frontmatter, fn)
      return [] unless frontmatter.is_a?(Hash)

      entries_for(frontmatter['trackers'], File.basename(fn, '.md'), frontmatter['ptimelog'], frontmatter['ticket'])
    end

    def inline_entries(body)
      body.each_line.flat_map do |line|
        next [] unless line.match?(TASK_RE)

        fields = fields_of(line)
        entries_for(fields['trackers'], description_of(line), fields['ptimelog'], fields['ticket'])
      end
    end

    def fields_of(line) = line.scan(FIELD_RE).to_h.transform_values(&:strip)

    def description_of(line)
      line.sub(TASK_RE, '').sub(/\s*\{\{.*\}\}\s*\z/m, '').strip
    end

    # A file task keeps its fields in frontmatter, an inline task carries them on its line
    def split_frontmatter(text)
      return [nil, text] unless text.start_with?('---')

      close = text.index("\n---", 3)
      return [nil, text] unless close

      [YAML.safe_load(text[4...close], permitted_classes: [Date, Time], aliases: true), text[(close + 4)..]]
    rescue Psych::Exception
      [nil, text]
    end

    def entries_for(sessions, description, tags, ticket)
      session_list(sessions).filter_map do |session|
        next unless started_on?(session)

        entry_for(session, description, tags, ticket)
      end
    end

    # Malformed ranges are dropped, one broken note must not sink a whole day
    def session_list(sessions)
      list = sessions.is_a?(String) ? sessions.split('; ') : Array(sessions)

      list.filter_map { |session| RANGE_RE.match(session.to_s.strip) }
    end

    def started_on?(session)
      Time.parse(session[:start]).strftime('%F') == @day
    end

    def entry_for(session, description, tags, ticket)
      Ptimelog::Entry.new.tap do |entry|
        entry.date        = @day
        entry.ticket      = ticket
        entry.description = description
        entry.tags        = tags
        entry.start_time  = Time.parse(session[:start]).strftime('%R')
        entry.finish_time = Time.parse(session[:stop]).strftime('%R')

        entry.infer_ptime_settings
      end
    end
  end
end
