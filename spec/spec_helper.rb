# frozen_string_literal: true
require 'fakeredis/rspec'

if ENV['COVERAGE'] == "true"
  require 'simplecov'

  SimpleCov.start do
    load_profile "test_frameworks"

    add_filter "/vendor/"
  end
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'feature_flagger'
require 'active_support'
