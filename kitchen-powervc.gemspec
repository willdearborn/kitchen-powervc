# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/powervc_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-powervc'
  spec.version       = Kitchen::Driver::POWERVC_VERSION
  spec.authors       = ['Benoit Creau']
  spec.email         = ['benoit.creau@chmod666.org']
  spec.description   = %q{A Test Kitchen Driver for Powervc}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/chmod666org/kitchen-powervc'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'test-kitchen', '>= 1.0.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'

  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'tailor'
  spec.add_development_dependency 'countloc'
end
