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

      def add(key, value)
        @redis.sadd(key, value)
      end

      def remove(key, value)
        @redis.srem(key, value)
      end

      def all_values(key)
        @redis.smembers(key)
      end
    end
  end
end
