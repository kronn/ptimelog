# frozen_string_literal: true

module Ptimelog
  module Command
    # show entries of one day or all of them
    class Show < CmdParse::Command
      attr_reader :entries

      def initialize
        super('show', takes_commands: false)
        @debug = false
        @durations = false
        @entries = {}
        @config = Configuration.instance

        options.on('-d', '--durations', 'Summarize durations by ticket') { @durations = true }
        options.on('--debug', 'Show debugging output') { @debug = true }
      end

      def execute(maybe_named_day) # rubocop:disable Metrics/AbcSize
        debug("Requested Day: #{maybe_named_day}")
        @day = Ptimelog::NamedDate.new.named_date(maybe_named_day)
        debug("Resolved Day: #{@day}")
        @entries = Ptimelog::DataSource.new(@config, @day).entries
        debug("Found Entries: #{@entries.values.sum(&:size)}")

        @entries.each do |date, list|
          next if list.empty?

          valids = Ptimelog::Joiner.new(@durations).join_similar(
            list.select(&:valid?).sort_by { |entry| entry.ticket.to_s }
          ).sort_by(&:start_time)
          total_duration = duration(valids.sum(&:duration))

          output(date, valids, total_duration)
        end
      end

      private

      def output(date, entries, total_duration)
        puts date,
             '----------'

        entries.each do |entry|
          puts entry
        end

        puts '----------',
             "Total work done: #{total_duration} hours",
             '----------------------------',
             nil
      end

      def debug(msg)
        return unless @debug

        warn msg
      end

      def duration(durations) = Time.at(durations).utc.strftime('%H:%M')
    end
  end
end
