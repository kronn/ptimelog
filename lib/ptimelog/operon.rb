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

    # A missing vault would silently look like a day without any tracked time
    class VaultNotFound < Ptimelog::Error
      def initialize(path)
        super(<<~MSG)
          Could not find your Obsidian vault at #{path}

          Please check 'obsidian_vault' in your ptimelog-config. It should
          point to the folder which contains your '.obsidian'-directory.
        MSG
      end
    end

    # A session belongs to the day it started on. Plans and running timers are no time yet
    def entries
      tasks.flat_map { |task| entries_of(task) }
           .sort_by(&:start_time)
    end

    # What a new entry would continue from: a running timer, the last session, the start of the day
    def previous_entry
      start = running_timer || entries.last&.finish_time || @configuration['operon_start_time'] || '08:00'

      Ptimelog::Entry.new.tap do |entry|
        entry.date        = @day
        entry.description = 'start **'
        entry.start_time  = start
        entry.finish_time = start
      end
    end

    # An entry can come from any note of the vault, so there is no one file to point at
    def file = NullPathname.new

    private

    def vault
      @vault ||= begin
        path = @configuration['obsidian_vault']
        raise VaultNotFound, path unless File.directory?(path)

        path
      end
    end

    def markdown_files
      Dir.glob(vault.join('**/*.md')).reject { |fn| ignored?(fn) }
    end

    def ignored?(fn)
      relative = fn.delete_prefix("#{vault}/")

      SKIP_PATHS.any? { |path| relative.start_with?("#{path}/") }
    end

    # Every task of the vault, an inline one on its line, a file task in its frontmatter
    def tasks
      markdown_files.flat_map do |fn|
        frontmatter, body = split_frontmatter(File.read(fn, encoding: 'UTF-8'))

        file_tasks(frontmatter, fn) + inline_tasks(body)
      end
    end

    def file_tasks(frontmatter, fn)
      return [] unless frontmatter.is_a?(Hash)

      [{ fields: frontmatter, description: File.basename(fn, '.md') }]
    end

    def inline_tasks(body)
      body.each_line.filter_map do |line|
        next unless line.match?(TASK_RE)

        { fields: fields_of(line), description: description_of(line) }
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

    def entries_of(task)
      session_list(task[:fields]['trackers']).filter_map do |session|
        next unless on_day?(session[:start])

        entry_for(session, task)
      end
    end

    # Malformed ranges are dropped, one broken note must not sink a whole day
    def session_list(sessions)
      list = sessions.is_a?(String) ? sessions.split('; ') : Array(sessions)

      list.filter_map { |session| RANGE_RE.match(session.to_s.strip) }
    end

    # A running timer is no session yet, but it says where the work stopped
    def running_timer
      started = tasks.filter_map { |task| task[:fields]['activeTracker'] }.find { |at| on_day?(at) }

      started && Time.parse(started).strftime('%R')
    end

    def on_day?(datetime)
      Time.parse(datetime).strftime('%F') == @day
    end

    def entry_for(session, task) # rubocop:disable Metrics/AbcSize
      fields = task[:fields]

      Ptimelog::Entry.new.tap do |entry|
        entry.date        = @day
        entry.ticket      = fields['ticket'] # TODO: extract field-name into config setting
        entry.description = task[:description]
        entry.tags        = fields['ptimelog'] # TODO: extract field-name into config setting
        entry.start_time  = Time.parse(session[:start]).strftime('%R')
        entry.finish_time = Time.parse(session[:stop]).strftime('%R')

        entry.infer_ptime_settings
      end
    end
  end
end
