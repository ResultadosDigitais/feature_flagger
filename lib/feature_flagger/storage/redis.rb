require 'redis'
require 'redis-namespace'

module FeatureFlagger
  module Storage
    class Redis

      DEFAULT_NAMESPACE = :feature_flagger

      def initialize(redis)
        @redis = redis
      end

      def self.default_client
        redis = ::Redis.new(url: ENV['REDIS_URL'])
        ns = ::Redis::Namespace.new(DEFAULT_NAMESPACE, :redis => redis)
        new(ns)
      end

      # Public: fetch_releases get all feature_keys related
      # to a resource and the global release structure.
      #
      # resource_key  - The String representing the resource.
      # global_key    - The String representing the key to global structure.
      #
      # Example:
      #
      # resource_key = 'account:42'
      # global_key   = 'released_to_all_key'
      #
      # fetch_releases(resource_key, global_key) #=> ['account:email_marketing:whitelabel']
      def fetch_releases(resource_key, global_key)
        @redis.sunion(resource_key, global_key)
      end

      def has_value?(key, value)
        @redis.sismember(key, value)
      end

      def add(key, value)
        @redis.sadd(key, value)
      end

      def remove(key, value)
        @redis.srem(key, value)
      end

      def remove_all(global_key, key)
        @redis.multi do |redis|
          redis.srem(global_key, key)
          redis.del(key)
        end
      end

      def add_all(global_key, key)
        @redis.multi do |redis|
          redis.sadd(global_key, key)
          redis.del(key)
        end
      end

      def all_values(key)
        @redis.smembers(key)
      end

      def search_keys(query)
        @redis.scan_each(match: query)
      end
    end
  end
end
