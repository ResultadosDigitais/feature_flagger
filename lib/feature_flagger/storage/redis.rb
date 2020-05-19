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

      def has_value?(key, value)
        @redis.sismember(key, value)
      end

      def add_single(key, value)
        @redis.sadd(key, value)
      end

      def add(key, value, resource_key)
        @redis.multi do |redis|
          redis.sadd(key, value)
          redis.sadd(resource_key, key)
        end
      end

      def remove(key, value, resource_key)
        @redis.multi do |redis|
          redis.srem(key, value)
          redis.srem(resource_key, key)
        end
      end

      def all_keys(global_key, resource_key)
        @redis.sunion(global_key, resource_key)
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
