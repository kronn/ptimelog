# frozen_string_literal: true

module Ptimelog
  module Command
    # show entries of one day or all of them
    class Confirm < CmdParse::Command
      attr_reader :entries

      def initialize
        super('confirm', takes_commands: false)
        @durations = false
        @dry_run = false
        @entries = {}
        @config = Configuration.instance

        options.on('-d', '--durations', 'Summarize durations by ticket') { @durations = true }
        options.on('-n', '--dry-run', 'Do not execute, just dry-run') { @dry_run = true }
      end

      def execute(maybe_named_day) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
        @day = Ptimelog::NamedDate.new.named_date(maybe_named_day)
        @entries = Ptimelog::DataSource.new(@config, @day).entries

        @entries.each do |date, list|
          next if list.empty?

          valids = Ptimelog::Joiner.new(compact_on_ticket_only: @durations).join_similar(
            list.select(&:valid?).sort_by { |entry| entry.ticket.to_s }
          ).sort_by(&:start_time)
          total_duration = duration(valids.sum(&:duration))

          output(date, valids, total_duration)

          upload(date) if ask('Upload this day? [Yn]', 'y').downcase == 'y'
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

      def ask(question, default = nil)
        puts question

        answer = $stdin.gets.chomp.strip

        if answer.empty?
          raise 'No answer and no default given' if default.nil?

          default
        else
          answer
        end
      end

      def upload(date)
        options = @durations ? '-d' : ''
        cmd = "#{$PROGRAM_NAME} upload #{date} #{options}"

        if @dry_run
          puts cmd
        else
          system(cmd)
        end
      end

      def duration(durations) = Time.at(durations).utc.strftime('%H:%M')
    end
  end
end
