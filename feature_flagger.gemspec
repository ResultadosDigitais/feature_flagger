# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'feature_flagger/version'

Gem::Specification.new do |spec|
  spec.name          = "feature_flagger"
  spec.version       = FeatureFlagger::VERSION
  spec.authors       = ["Nando Sousa", "Geison Biazus"]
  spec.email         = ["nandosousafr@gmail.com", "geisonbiazus@gmail.com"]
  spec.licenses      = ['MIT']

  spec.summary       = %q{Partial release your features.}
  spec.description   = %q{Management tool to make it easier rollouting features to customers.}
  spec.homepage      = "http://github.com/ResultadosDigitais/feature_flagger"

  spec.files         = Dir['README.md', 'MIT-LICENSE', 'lib/**/*']
  spec.require_paths = ["lib"]

  spec.add_dependency 'redis', '~> 3.2'
  spec.add_dependency 'redis-namespace', '~> 1.3'
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "fakeredis"
end
