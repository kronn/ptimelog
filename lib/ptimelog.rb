# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

# Autoloading and such
module Ptimelog
  autoload :App, 'ptimelog/app'
  autoload :Configuration, 'ptimelog/configuration'
  autoload :Day, 'ptimelog/day'
  autoload :DeprecationWarning, 'ptimelog/deprecation_warning'
  autoload :Entry, 'ptimelog/entry'
  autoload :NamedDate, 'ptimelog/named_date'
  autoload :NullPathname, 'ptimelog/null_pathname'
  autoload :Script, 'ptimelog/script'
  autoload :Timelog, 'ptimelog/timelog'
  autoload :VERSION, 'ptimelog/version'

  # Collection of commands available at the CLI
  module Command
    autoload :Add, 'ptimelog/command/add'
    autoload :Base, 'ptimelog/command/base'
    autoload :Edit, 'ptimelog/command/edit'
    autoload :Show, 'ptimelog/command/show'
    autoload :Upload, 'ptimelog/command/upload'
    autoload :Version, 'ptimelog/command/version'
  end
end
