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
        launch_editor(find_file(@file))
      end

      private

      def launch_editor(file)
        editor = `which $EDITOR`.chomp

        exec "#{editor} #{file}"
      end

      def find_file(requested_file)
        %i[
          timelog
          existing_inferer
          empty_inferer
        ].each do |file_lookup|
          valid, filename = send(file_lookup, requested_file)

          return filename if valid
        end
      end

      def timelog(file)
        [file.nil?, Timelog.timelog_txt]
      end

      def existing_inferer(file)
        fn = @scripts.inferer(file)

        [fn.exist?, fn]
      end

      def empty_inferer(file)
        [true, @scripts.inferer(file)]
      end
    end
  end
end
