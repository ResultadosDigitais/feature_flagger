require 'yaml'
require 'redis-namespace'

require 'feature_flagger/version'
require 'feature_flagger/storage/redis'
require 'feature_flagger/control'
require 'feature_flagger/model'
require 'feature_flagger/feature'

module FeatureFlagger
  DEFAULT_CONFIG = { redis_namespace: 'rollout-control' }

  class << self
    def configure(&block)
      set_config
      yield self if block_given?
    end

    # TODO: rename to just _config_.
    def config
      @@config
    end

    def redis
      redis_conn = @@config[:redis]
      namespace  = @@config[:redis_namespace]
      @@redis ||= Redis::Namespace.new(namespace, redis: redis_conn)
    end

    def redis=(conn)
      set_config
      @@config[:redis] = conn
    end

    def redis_namespace=(namespace)
      set_config
      @@config[:redis_namespace] = namespace
    end

    private

    def set_config
      @@config ||= DEFAULT_CONFIG

      # TODO: Provide a Rake to generate initial YAML file
      # for new projects.

      if defined?(Rails)
        @@config[:yaml_filepath] ||= "#{Rails.root}/config/rollout.yml"
      end

      if file_path = @@config[:yaml_filepath]
        @@config[:info] ||= YAML.load_file(file_path)
      end
    end
  end
end
