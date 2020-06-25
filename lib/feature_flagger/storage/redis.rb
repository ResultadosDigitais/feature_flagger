require 'redis'
require 'redis-namespace'
require_relative './redis_keys'

module FeatureFlagger
  module Storage
    class Redis
      DEFAULT_NAMESPACE = :feature_flagger
      RESOURCE_PREFIX = "_r".freeze
      SCAN_EACH_BATCH_SIZE = 1000.freeze

      def initialize(redis)
        @redis = redis
      end

      def self.default_client
        redis = ::Redis.new(url: ENV['REDIS_URL'])
        ns = ::Redis::Namespace.new(DEFAULT_NAMESPACE, :redis => redis)
        new(ns)
      end

      def fetch_releases(resource_name, resource_id, global_key)
        resource_key = resource_key(resource_name, resource_id)
        @redis.sunion(resource_key, global_key)
      end

      def has_value?(key, value)
        @redis.sismember(key, value)
      end

      def add(feature_key, resource_name, resource_id)
        resource_key = resource_key(resource_name, resource_id)

        @redis.multi do |redis|
          redis.sadd(feature_key, resource_id)
          redis.sadd(resource_key, feature_key)
        end
      end

      def remove(feature_key, resource_name, resource_id)
        resource_key = resource_key(resource_name, resource_id)

        @redis.multi do |redis|
          redis.srem(feature_key, resource_id)
          redis.srem(resource_key, feature_key)
        end
      end

      def remove_all(global_key, feature_key)
        @redis.multi do |redis|
          redis.srem(global_key, feature_key)
          redis.del(feature_key)
        end

        remove_feature_key_from_resources(feature_key)
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

      private

      def resource_key(resource_name, resource_id)
        FeatureFlagger::Storage::RedisKeys.resource_key(
          RESOURCE_PREFIX,
          resource_name,
          resource_id,
        )
      end

      def remove_feature_key_from_resources(feature_key)
        cursor = 0

        loop do
          cursor, resource_keys = @redis.scan(cursor, match: "#{RESOURCE_PREFIX}:*", count: SCAN_EACH_BATCH_SIZE)
          
          @redis.multi do |redis|
            resource_keys.each do |key|
              redis.srem(key, feature_key)
            end
          end

          break if cursor == "0"
        end
      end
    end
  end
end
