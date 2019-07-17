# frozen_string_literal: true

module Gpuzzletime
  module Command
    # Upload entries to puzzletime
    class Upload
      attr_writer :entries

      def initialize(config)
        @config  = config
        @entries = {}
      end

      def needs_entries?
        true
      end

      def run
        @entries.each do |date, list|
          puts "Uploading #{date}"
          list.each do |entry|
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
            https://github.com/kronn/gpuzzletime/issues/new
          ERRORMESSAGE
        end
      end

      def url_options(entry)
        {
          work_date:                    entry.date,
          'ordertime[ticket]':          entry.ticket,
          'ordertime[description]':     entry.description,
          'ordertime[from_start_time]': entry.start_time,
          'ordertime[to_end_time]':     entry.finish_time,
          'ordertime[account_id]':      entry.account,
          'ordertime[billable]':        entry.billable,
        }
          .map { |key, value| [key, ERB::Util.url_encode(value)].join('=') }
          .join('&')
      end
    end
  end
end
