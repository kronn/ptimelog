# frozen_string_literal: true

require 'pathname'
require 'erb'

# Wrapper for everything
class Gpuzzletime
  def initialize(args)
    @base_url = 'https://time.puzzle.ch'

    @command  = (args[0] || :show).to_sym  # show, upload
    raise ArgumentError unless %i(show upload).include?(@command)

    @date     = args[1] || :all
  end

  def run
    @entries = {}

    parse(read).each do |date, entries|
      # this is mixing preparation, assembly and output, but it gets the job done
      next unless date                             # guard against the machine
      next unless (@date == :all || @date == date) # limit to one day if one is passed
      @entries[date] = []

      start = nil             # at the start of the day, we have no previous end

      entries.each do |entry|
        finish = entry[:time] # we use that twice
        hidden = entry[:description].match(/\*\*$/) # hide lunch and breaks

        if start && !hidden
          case @command # assemble data according to command
          when :show
            @entries[date] << [
              start, '-', finish,
              [entry[:ticket], entry[:description]].compact.join(': '),
            ].compact.join(' ')
          when :upload
            @entries[date] << [start, entry]
          end
        end

        start = finish # store previous ending for nice display of next entry
      end
    end

    case @command
    when :show
      @entries.each do |date, entries|

        puts date, '----------'
        entries.each do |entry|
          puts entry
        end
        puts nil
      end
    when :upload
      @entries.each do |date, entries|
        puts "Uploading #{date}"
        entries.each do |start, entry|
          open_browser(start, entry)
        end
      end
    end
  end

  private

  def open_browser(start, entry)
    system "gnome-open '#{@base_url}/ordertimes/new?#{url_options(start, entry)}'"
  end

  def url_options(start, entry)
    {
      work_date:                    entry[:date],
      'ordertime[ticket]':          entry[:ticket],
      'ordertime[description]':     entry[:description],
      'ordertime[from_start_time]': start,
      'ordertime[to_end_time]':     entry[:time],
    }.map { |key, value|
      [key, ERB::Util.url_encode(value)].join('=')
    }.join('&')
  end

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
