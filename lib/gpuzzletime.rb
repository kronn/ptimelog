# frozen_string_literal: true

require 'pathname'

# Wrapper for everything
class Gpuzzletime
  def initialize(*_); end

  def run
    parse(read).each do |date, entries|
      # this is mixing preparation, assembly and output, but it gets the job done
      next unless date        # guard
      puts date, '----------' # date start
      start = nil             # at the start of the day, we have no previous end

      entries.each do |entry|
        finish = entry[:time] # we use that twice
        hidden = entry[:description].match(/\*\*$/) # hide lunch and breaks

        if start && !hidden
          puts [
            start, '-', finish,
            [entry[:ticket], entry[:description]].compact.join(': '),
          ].compact.join(' ')
        end

        start = finish # store previous ending for nice display of next entry
      end
      puts
    end
    nil
  end

  private

  def read
    Pathname.new('~/.local/share/gtimelog/timelog.txt').expand_path.read
  end

  def parse(data)
    data.split("\n").map do |line|
      tokenize(line)
    end.group_by do |match|
      match && match[:date]
    end.to_a
  end

  def tokenize(line)
    regexp = /(?<date>\d{4}-\d{2}-\d{2}) (?<time>\d{2}:\d{2}): (?:(?<ticket>.*): )?(?<description>.*)/
    line.match(regexp)
  end
end
