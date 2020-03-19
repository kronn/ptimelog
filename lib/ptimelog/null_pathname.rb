# typed: true
# frozen_string_literal: true

require 'naught'
require 'pathname'

NullPathname = Naught.build do |config|
  config.impersonate Pathname
  config.predicates_return false
end
