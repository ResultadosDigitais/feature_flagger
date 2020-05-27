# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'feature_flagger/version'

Gem::Specification.new do |spec|
  spec.name          = 'feature_flagger'
  spec.version       = FeatureFlagger::VERSION
  spec.authors       = ['Nando Sousa', 'Geison Biazus']
  spec.email         = ['nandosousafr@gmail.com', 'geisonbiazus@gmail.com']
  spec.licenses      = ['MIT']

  spec.summary       = 'Partial release your features.'
  spec.description   = 'Management tool to make it easier rollouting features to customers.'
  spec.homepage      = 'http://github.com/ResultadosDigitais/feature_flagger'

  spec.required_ruby_version = '>= 2.5'
  spec.required_rubygems_version = '>= 2.0.0'

  spec.files         = Dir['README.md', 'MIT-LICENSE', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'redis', '> 3.2'
  spec.add_dependency 'redis-namespace', '> 1.3'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fakeredis', '0.8.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
