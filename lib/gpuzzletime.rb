# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

# Autoloading and such
module Gpuzzletime
  autoload :App, 'gpuzzletime/app'
  autoload :Configuration, 'gpuzzletime/configuration'
  autoload :Entry, 'gpuzzletime/entry'
  autoload :Script, 'gpuzzletime/script'
  autoload :Timelog, 'gpuzzletime/timelog'
  autoload :VERSION, 'gpuzzletime/version'

  # Collection of commands available at the CLI
  module Command
    autoload :Edit, 'gpuzzletime/command/edit'
    autoload :Show, 'gpuzzletime/command/show'
    autoload :Upload, 'gpuzzletime/command/upload'
  end
end
