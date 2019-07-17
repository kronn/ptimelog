# frozen_string_literal: true

module Gpuzzletime
  module Command
    # edit one file. without argument, it will edit the timelog, otherwise a
    # parser-script is loaded
    class Edit
      def initalize(config, file)
        @config = config
        @script = Script.new(@config[:dir])
        @file   = file
      end

      def needs_entries?
        false
      end

      def run
        launch_editor(@file)
      end

      private

      def launch_editor(file)
        editor = `which $EDITOR`.chomp

        file = file.nil? ? Timelog.timelog_txt : @script.parser(@file)

        exec "#{editor} #{file}"
      end
    end
  end
end
