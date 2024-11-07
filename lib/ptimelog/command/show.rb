# frozen_string_literal: true

module Ptimelog
  module Command
    # show entries of one day or all of them
    class Show < CmdParse::Command
      attr_reader :entries

      def initialize
        super('show', takes_commands: false)
        @entries = {}
        @config = Configuration.instance
      end

      def execute(maybe_named_day)
        @day = Ptimelog::NamedDate.new.named_date(maybe_named_day)
        @entries = Ptimelog::DataSource.new(@config, @day).entries

        @entries.each do |date, list|
          next if list.empty?

          valids = list.select(&:valid?)
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

      def duration(durations) = Time.at(durations).utc.strftime('%H:%M')
    end
  end
end
