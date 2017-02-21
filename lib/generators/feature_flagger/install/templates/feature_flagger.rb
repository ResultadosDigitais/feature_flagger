# File for Feature Flagger configure
# https://github.com/ResultadosDigitais/feature_flagger#configuration

# require 'redis-namespace'
require 'feature_flagger'

FeatureFlagger.configure do |config|
  # namespaced = ::Redis::Namespace.new("feature_flagger", redis: $redis)
  # config.storage = FeatureFlagger::Storage::Redis.new(namespaced)
end
