# frozen_string_literal: true

require 'time'

module Ptimelog
  # Dataclass to wrap an entry
  class Entry
    SEPARATOR = '|'

    # define only trivial writers, omit special and derived values
    attr_accessor :date, :ticket, :description

    # allow to read everything else
    attr_reader :start_time, :finish_time, :tags, :billable, :account, :publishable

    BILLABLE     = 1
    NON_BILLABLE = 0

    def initialize(config = Configuration.instance)
      @config = config
      @script = Script.new(@config[:dir])
    end

    class << self
      def from_timelog(matched_line)
        entry = new
        entry.from_timelog(matched_line)
        entry
      end
    end

    def from_timelog(matched_line)
      self.date        = matched_line[:date]
      self.ticket      = matched_line[:ticket]
      self.description = matched_line[:description]
      self.finish_time = matched_line[:time]
      self.tags        = matched_line[:tags]

      infer_ptime_settings
    end

    def start_time=(time)
      @start_time = round_time(time, @config[:rounding])
    end

    def finish_time=(time)
      @finish_time = round_time(time, @config[:rounding])
    end

    def tags=(tags)
      @tags = case tags
              when '', nil then nil
              else tags.split.compact
              end
    end

    def valid? = @start_time && duration.positive? && !hidden?

    # hide lunch and breaks
    def hidden? = @description.to_s.end_with?('**')

    # or something like @tags.to_a.include?('special-team')
    def selected? = true

    def billable? = @billable == BILLABLE

    def publishable? = @publishable != false

    def infer_ptime_settings
      return if hidden?
      return unless @script.inferer(script_name).exist?

      @account, @billable, @publishable = infer_entry_attributes
    end

    def duration
      (Time.parse(@finish_time) - Time.parse(@start_time)).to_i
    end

    def duration_hours
      format('%.02f', duration / 3600.0)
    end

    def to_s
      billable = billable? ? '($)' : nil

      tags = tag_list.join(' ') if tag_list.any?
      desc = [@ticket, @description].compact.join(': ')
      acc  = [@account, billable].compact.join(' ') if @account

      [
        @start_time, '-', @finish_time, SEPARATOR,
        "#{duration_hours}h", SEPARATOR,
        [desc, tags, acc].compact.join(" #{SEPARATOR} "),
      ].compact.join(' ')
    end

    # make sortable/def <=>

    private

    def tag_list = Array(@tags).compact

    def round_time(time, interval)
      return time unless interval
      return unless /\d\d:\d\d/.match?(time.to_s)

      hour, minute = time.split(':')
      minute = (minute.to_i / interval.to_f).round * interval.to_i

      if minute == 60
        [hour.succ, 0]
      else
        [hour, minute]
      end.map { |part| part.to_s.rjust(2, '0') }.join(':')
    end

    def script_name
      @script_name ||= @tags.to_a.first.to_s
    end

    def script_args
      @script_args ||= @tags.to_a[1..].to_a.map(&:inspect).join(' ')
    end

    def infer_entry_attributes
      script = @script.inferer(script_name)

      cmd = %(#{script} "#{@ticket}" "#{@description}" #{script_args})

      results = `#{cmd}`.chomp.split
      account = results[0]
      billable = ((results[1] || 'false').to_s == 'true' ? BILLABLE : NON_BILLABLE)
      publishable = ((results[2] || 'true').to_s == 'true')

      [account, billable, publishable]
    end
  end
end
