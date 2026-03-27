# frozen_string_literal: true

require 'singleton'
require 'pathname'

module Ptimelog
  # Load and tokenize the data from gtimelog
  class Timelog
    include Singleton

    class << self
      def load
        instance.load
      end

      def timelog_txt
        Pathname.new(Configuration.instance[:timelog_txt]).expand_path
      end

      def previous_entry
        lines = timelog_txt.readlines.last(10)

        last_line = lines.map(&:chomp).delete_if do |line|
          line.empty? || line.end_with?('**')
        end.last

        last_entry = instance.tokenize(last_line)

        Entry.from_timelog(last_entry)
      end
    end

    def load
      @load ||= parse(read)
    end

    def timelog_txt
      self.class.timelog_txt
    end

    def previous_entry
      self.class.previous_entry
    end

    def read
      timelog_txt.read
    end

    # TODO: spec and activate this code
    # def add(_entry)
    #   @new_lines = []
    #   add_empty_line if @timelog.previous_entry.date == yesterday
    #   add_entry(*parse_task(task))
    #
    #   save_file
    # end

    def parse(data)
      data.split("\n")
          .map { |line| tokenize(line) }
          .group_by { |match| match && match[:date] }
          .to_a
    end

    def tokenize(line)
      re_date = /(?<date>\d{4}-\d{2}-\d{2})/
      re_time = /(?<time>\d{2}:\d{2})/
      re_tick = /(?:(?<ticket>.*?): )/
      re_desc = /(?<description>.*?)/
      re_tags = /(?: -- (?<tags>.*)?)/

      regexp = /^#{re_date} #{re_time}: #{re_tick}?#{re_desc}#{re_tags}?$/
      line.match(regexp)
    end

    # TODO: spec and maybe activate this code. this might be covered by the "add"-command already.
    # def parse_task(line)
    #   matches = line.match('(?<time>\d{1,2}:\d{2} )?(?<offset>[+-]\d+ )?(?<task>.*)')
    #   formatted_time = if matches[:time]
    #                      Time.parse(matches[:time])
    #                    else
    #                      Time.now
    #                    end
    #                    .localtime
    #                    .then { |time| time + (matches[:offset].to_i * 60) }
    #                    .strftime('%F %R')
    #
    #   [formatted_time, matches[:task]]
    # end

    # TODO: spec and activate this code.
    # def add_entry(date_time, task)
    #   @new_lines << "#{date_time}: #{task}"
    # end

    # TODO: spec and activate this code.
    # def add_empty_line
    #   @new_lines << ''
    # end

    # TODO: spec and activate this code.
    # def save_file
    #   @timelog.timelog_txt.open('a') do |log|
    #     @new_lines.each do |line|
    #       log << "#{line}\n"
    #     end
    #   end
    # end

    # TODO: spec and activate this code.
    # def yesterday
    #   NamedDate.new.named_date('yesterday')
    # end
  end
end
