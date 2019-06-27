# frozen_string_literal: true

require 'pathname'

module Gpuzzletime
  # Load and tokenize the data from gtimelog
  class Timelog
    class << self
      def load
        new.load
      end

      def timelog_txt
        Pathname.new('~/.local/share/gtimelog/timelog.txt').expand_path
      end
    end

    def load
      parse(read)
    end

    def timelog_txt
      self.class.timelog_txt
    end

    def read
      timelog_txt.read
    end

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
  end
end
