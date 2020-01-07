# frozen_string_literal: true

module Ptimelog
  # Dataclass to wrap an entry
  class Entry
    # allow to read everything
    attr_reader :date, :start_time, :finish_time, :ticket, :description,
                :tags, :billable, :account

    # define only trivial writers, omit special and derived values
    attr_writer :date,                            :ticket, :description

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

    def valid?
      @start_time && !hidden?
    end

    def hidden?
      @description.to_s.end_with?('**') # hide lunch and breaks
    end

    def billable?
      @billable == BILLABLE
    end

    def infer_ptime_settings
      return if hidden?

      if @script.inferer(script_name).exist?
        @account, @billable = infer_account_and_billable
      else
        @account  = infer_account
        @billable = infer_billable
      end
    end

    def to_s
      [
        @start_time, '-', @finish_time,
        [@ticket, @description, @tags, @account].compact.join(' : '),
      ].compact.join(' ')
    end

    # make sortable/def <=>
    # duration if start and finish is set

    private

    def round_time(time, interval)
      return time unless interval
      return unless time.to_s =~ /\d\d:\d\d/

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
      @script_args ||= @tags.to_a[1..-1].to_a.map(&:inspect).join(' ')
    end

    def infer_account
      parser = @script.parser(script_name)
      return unless parser.exist?

      @script.deprecate(parser)

      cmd = %(#{parser} "#{@ticket}" "#{@description}" #{script_args})
      `#{cmd}`.chomp # maybe only execute if parser is in correct dir?
    end

    def infer_billable
      script = @script.billable
      return BILLABLE unless script.exist?

      @script.deprecate(script)

      `#{script} #{@account}`.chomp == 'true' ? BILLABLE : NON_BILLABLE
    end

    def infer_account_and_billable
      script = @script.inferer(script_name)

      cmd = %(#{script} "#{@ticket}" "#{@description}" #{script_args})

      account, billable = `#{cmd}`.chomp.split

      [account, (billable == 'true' ? BILLABLE : NON_BILLABLE)]
    end
  end
end
