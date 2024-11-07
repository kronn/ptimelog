# frozen_string_literal: true

require 'erb'

module Ptimelog
  module Command
    # Upload entries to puzzletime
    class Upload < CmdParse::Command
      def initialize
        super('upload', takes_commands: false)

        @durations = false
        @entries = {}
        @config = Configuration.instance

        options.on('-d', '--durations', 'Only upload durations') { @durations = true }
      end

      def execute(maybe_named_day)
        @day = Ptimelog::NamedDate.new.named_date(maybe_named_day)
        @entries = Ptimelog::DataSource.new(@config, @day).entries

        @entries.each do |date, list|
          next if list.empty?

          valids = list.select(&:valid?)

          puts "Uploading #{date}"
          valids.each do |entry|
            open_browser(entry)
          end
        end
      end

      private

      def open_browser(entry)
        xdg_open "'#{@config[:base_url]}/ordertimes/new?#{url_options(entry)}'", silent: true
      end

      def xdg_open(args, silent: false)
        opener   = 'xdg-open' # could be configurable, but is already a proxy
        silencer = '> /dev/null 2> /dev/null'

        if system("which #{opener} #{silencer}")
          system "#{opener} #{args} #{silencer if silent}"
        else
          abort <<~ERRORMESSAGE
            #{opener} not found

            This binary is needed to launch a webbrowser and open the page
            to enter the worktime-entry into puzzletime.

            If this needs to be configurable, please open an issue at
            https://github.com/kronn/ptimelog/issues/new
          ERRORMESSAGE
        end
      end

      def url_options(entry)
        base_params(entry)
          .merge(duration_params(entry))
          .map { |key, value| [key, ERB::Util.url_encode(value)].join('=') }
          .join('&')
      end

      def base_params(entry)
        {
          work_date:                entry.date,
          'ordertime[ticket]':      entry.ticket,
          'ordertime[description]': entry.description,
          'ordertime[account_id]':  entry.account,
          'ordertime[billable]':    entry.billable,
        }
      end

      def duration_params(entry)
        if @durations
          {
            'ordertime[hours]': entry.duration_hours,
          }
        else
          {
            'ordertime[from_start_time]': entry.start_time,
            'ordertime[to_end_time]':     entry.finish_time,
          }
        end
      end
    end
  end
end
