require 'rollout/version'
require 'rollout/control'
require 'redis-namespace'
require 'rollout/helpers' if defined?(Rails)
require 'rollout/model'   if defined?(Rails)

module Rollout
  DEFAULT_CONFIG = {
    resource_method: :current_account,
    redis_namespace: 'rollout-control'
  }

  class << self
    def configure(&block)
      set_config
      yield self if block_given?
    end

    # TODO: rename to just _config_.
    def configuration
      @@configuration
    end

    def redis
      redis_conn = @@configuration[:redis]
      namespace  = @@configuration[:redis_namespace]
      @@redis ||= Redis::Namespace.new(namespace, redis: redis_conn)
    end

    def redis=(conn)
      set_config
      @@configuration[:redis] = conn
    end

    def resource_method=(method_name)
      set_config
      @@configuration[:resource_method] = method_name
    end

    def redis_namespace=(namespace)
      set_config
      @@configuration[:redis_namespace] = namespace
    end

    private

    def set_config
      @@configuration ||= DEFAULT_CONFIG

      # TODO: Provide a Rake to generate initial YAML file
      # for new projects.

      if defined?(Rails)
        @@configuration[:yaml_filepath] ||= "#{Rails.root}/config/rollout.yml"
      end

      if file_path = @@configuration[:yaml_filepath]
        @@configuration[:info] ||= YAML.load_file(file_path)
      end
    end
  end
end
