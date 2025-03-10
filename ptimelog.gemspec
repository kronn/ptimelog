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

  spec.summary       = Ptimelog::BANNER
  # spec.description   = %q{}
  spec.homepage      = 'https://github.com/kronn/ptimelog'
  spec.license       = 'MIT'

  spec.files         = Rake::FileList['**/*'].exclude(*File.read('.gitignore').split)
                                             .exclude(%w[exe/gpuzzletime
                                                         *.gemspec
                                                         bin/* bin spec/**/* spec])
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'cmdparse' # as OptionParse-wrapper and cli-helper
  spec.add_dependency 'commonmarker' # for parsing Obsidian files for dayplanner-entries
  spec.add_dependency 'naught' # for NullPathname
  spec.add_dependency 'rake' # for Rake::FileList and rake in development

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'overcommit'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-packaging'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'timecop'
end
