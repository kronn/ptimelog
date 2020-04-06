# frozen_string_literal: true

require 'pathname'

module Ptimelog
  module Command
    # add a new entrie with the current date and time
    class Add < Base
      def initialize(task)
        super()

        @task = task
        @timelog = Ptimelog::Timelog.instance
      end

      def needs_entries?
        false
      end

      def run
        date_time = Time.now.strftime('%F %R')

        @timelog.timelog_txt.open('a') do |log|
          log << "#{date_time}: #{@task}\n"
        end
      end
    end
  end
end
