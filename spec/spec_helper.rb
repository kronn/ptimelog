# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'ptimelog'
require 'timecop'
require 'pathname'

def fixtures_dir
  Pathname.new(File.expand_path('./fixtures', __dir__))
end
