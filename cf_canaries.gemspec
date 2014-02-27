# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cf_canaries/version'

Gem::Specification.new do |spec|
  spec.name          = 'cf_canaries'
  spec.version       = CfCanaries::VERSION
  spec.authors       = ['Cloud Foundry Team']
  spec.email         = %w(cf-eng@pivotallabs.com)
  spec.summary       = %q{Tool to install 'canary' apps to detect anomalies on a Cloud Foundry deployment}
  spec.homepage      = 'http://github.com/pivotal-cf-experimental/cf_canaries'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
