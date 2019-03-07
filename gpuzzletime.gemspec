# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gpuzzletime/version'

Gem::Specification.new do |spec|
  spec.name          = 'gpuzzletime'
  spec.version       = Gpuzzletime::VERSION
  spec.authors       = ['Matthias Viehweger']
  spec.email         = ['kronn@kronn.de']

  spec.summary       = 'Move time-entries from gTimelog to PuzzleTime'
  # spec.description   = %q{}
  spec.homepage      = 'https://github.com/kronn/gpuzzletime'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'overcommit', '~> 0.45'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.50'
end
