# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

# Autoloading and such
module Ptimelog
  autoload :App, 'ptimelog/app'
  autoload :Configuration, 'ptimelog/configuration'
  autoload :DataSource, 'ptimelog/data_source'
  autoload :DeprecationWarning, 'ptimelog/deprecation_warning'
  autoload :Entry, 'ptimelog/entry'
  autoload :Error, 'ptimelog/error'
  autoload :NamedDate, 'ptimelog/named_date'
  autoload :NullPathname, 'ptimelog/null_pathname'
  autoload :Script, 'ptimelog/script'
  autoload :VERSION, 'ptimelog/version'

  # datasources

  # obsidian
  autoload :Obsidian, 'ptimelog/obsidian'

  # timelog.txt
  autoload :Day, 'ptimelog/day'
  autoload :Timelog, 'ptimelog/timelog'

  # Collection of commands available at the CLI
  module Command
    autoload :Add, 'ptimelog/command/add'
    autoload :Edit, 'ptimelog/command/edit'
    autoload :Info, 'ptimelog/command/info'
    autoload :Show, 'ptimelog/command/show'
    autoload :Upload, 'ptimelog/command/upload'
    autoload :Version, 'ptimelog/command/version'
  end
end
