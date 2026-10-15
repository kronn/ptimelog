# frozen_string_literal: true

module Ptimelog
  module Command
    # Extract and show entries from a Obsidian+DayPlanner list
    class Info < CmdParse::Command
      def initialize
        super('info', takes_commands: false)
        @configuration = Ptimelog::Configuration.instance
      end

      def execute
        puts <<~TXT
          Configuration
          -------------
          base_url:  #{@configuration['base_url']}
          rounding:  #{@configuration['rounding']}
          dir:       #{@configuration['dir']}

          #{obsidian_config}#{timelog_config}
        TXT
      end

      def obsidian_config
        return nil unless @configuration['obsidian']

        <<~TXT
          Datasource: Obsidian (Operon)
          -----------------------------
          vault:     #{@configuration['obsidian_vault']}
          custom keys:
            ticket:  #{Ptimelog::Operon.custom_keys['ticket']}
            inferer: #{Ptimelog::Operon.custom_keys['inferer']}
        TXT
      end

      def timelog_config
        return nil unless @configuration['timelog']

        <<~TXT
          Datasource: Timelog
          -------------------
          file:      #{@configuration['timelog_txt']}
        TXT
      end
    end
  end
end
