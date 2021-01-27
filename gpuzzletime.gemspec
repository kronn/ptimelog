# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'gpuzzletime'
  spec.version       = '0.5.2'
  spec.authors       = ['Matthias Viehweger']
  spec.email         = ['kronn@kronn.de']

  spec.summary       = 'The gem formerly known as gpuzzletime is now ptimelog'
  spec.homepage      = 'https://github.com/kronn/ptimelog'
  spec.license       = 'MIT'

  spec.files         = ['exe/gpuzzletime']
  spec.bindir        = 'exe'
  spec.executables   = ['gpuzzletime']

  spec.add_runtime_dependency 'ptimelog'

  spec.required_ruby_version = '2.7'

  spec.post_install_message = <<-MESSAGE
    gpuzzletime has been renamed to ptimelog. Along with this update, ptimelog
    has already been installed. The previous executable is now a
    migration-script.

    You can safely uninstall gpuzzletime. If you miss the executable
    gpuzzletime afterwards, you can recreate the migration-script version by
    reinstalling ptimelog.

    Sorry for the inconvenience.
  MESSAGE
end
