# frozen_string_literal: true

module Ptimelog
  module Command
    # edit one file. without argument, it will edit the timelog, otherwise a
    # parser-script is loaded
    class Edit < Base
      def initialize(file)
        super()

        @scripts = Script.new(@config[:dir])
        @file    = file
      end

      def run
        launch_editor(@file)
      end

      private

      def launch_editor(file)
        editor = `which $EDITOR`.chomp

        file = file.nil? ? Timelog.timelog_txt : @scripts.parser(@file)

        exec "#{editor} #{file}"
      end
    end
  end
end
