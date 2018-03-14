# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

# Autoloading and such
module Gpuzzletime
  autoload :App, 'gpuzzletime/app'
  autoload :VERSION, 'gpuzzletime/version'
end
