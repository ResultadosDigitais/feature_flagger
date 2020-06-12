# frozen_string_literal: true

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
        ns = ::Redis::Namespace.new(DEFAULT_NAMESPACE, redis: redis)
        new(ns)
      end

      def has_value?(feature_key, resource_name, resource_id)
        @redis.sismember("#{resource_name}:#{resource_id}", feature_key)
      end

      def add(feature_key, resource_name, resource_ids)
        @redis.multi do |redis|
          Array(resource_ids).each do |resource_id|
            redis.sadd("#{resource_name}:#{resource_id}", feature_key)
          end
        end
      end

      def remove(feature_key, resource_name, resource_ids)
        @redis.multi do |redis|
          Array(resource_ids).each do |resource_id|
            redis.srem("#{resource_name}:#{resource_id}", feature_key)
          end
        end
      end

      def all_feature_keys(global_features_key, resource_name, resource_id = nil)
        if resource_id
          return @redis.sunion(
            "#{resource_name}:#{global_features_key}",
            "#{resource_name}:#{resource_id}"
          )
        end

        @redis.smembers("#{resource_name}:#{global_features_key}")
      end

      def remove_all(feature_key, resource_name)
        keys = search_keys("#{resource_name}:*")

        @redis.multi do |redis|
          keys.map do |key|
            redis.srem(key, feature_key)
          end
        end
      end

      def add_all(global_features_key, feature_key, resource_name)
        keys = search_keys("#{resource_name}:*") - ["#{resource_name}:#{global_features_key}"]

        add(feature_key, resource_name, global_features_key)

        @redis.multi do |redis|
          keys.map do |key|
            redis.srem(key.to_s, feature_key)
          end
        end
      end

      def all_values(feature_key, resource_name)
        keys = search_keys("#{resource_name}:*")
        query = {}
        @redis.pipelined do |redis|
          keys.map do |key|
            query[key] = @redis.sismember(key, feature_key)
          end
        end

        query.map do |key, in_redis|
          next unless in_redis.value == true

          key.gsub("#{resource_name}:", '')
        end.compact
      end

      def search_keys(pattern)
        @redis.keys(pattern)
      end
    end
  end
end
