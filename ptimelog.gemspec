# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ptimelog/version'
require 'rake/file_list'

Gem::Specification.new do |spec|
  spec.name          = 'ptimelog'
  spec.version       = Ptimelog::VERSION
  spec.authors       = ['Matthias Viehweger']
  spec.email         = ['kronn@kronn.de']

  spec.summary       = 'Move time-entries from gTimelog to PuzzleTime'
  # spec.description   = %q{}
  spec.homepage      = 'https://github.com/kronn/ptimelog'
  spec.license       = 'MIT'

  spec.files         = Rake::FileList['**/*'].exclude(*File.read('.gitignore').split)
                                             .exclude(%w[gpuzzletime])
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'naught' # for NullPathname
  spec.add_dependency 'rake' # for Rake::FileList (see above) and rake in development

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'overcommit', '~> 0.45'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.50'
  spec.add_development_dependency 'rubocop-packaging'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  # spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'timecop', '~> 0.9'
end
