# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ptimelog/version'

Gem::Specification.new do |spec|
  spec.name          = 'ptimelog'
  spec.version       = Ptimelog::VERSION
  spec.authors       = ['Matthias Viehweger']
  spec.email         = ['kronn@kronn.de']

  spec.summary       = 'Move time-entries from gTimelog to PuzzleTime'
  # spec.description   = %q{}
  spec.homepage      = 'https://github.com/kronn/ptimelog'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{(gpuzzletime|^(test|spec|features)/)})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'naught'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'overcommit', '~> 0.45'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.50'
  spec.add_development_dependency 'rufo', '~> 0.10'
  spec.add_development_dependency 'timecop', '~> 0.9'
end
