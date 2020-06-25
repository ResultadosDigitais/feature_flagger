# frozen_string_literal: true
require 'fakeredis/rspec'

if ENV['COVERAGE'] == "true"
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'feature_flagger'