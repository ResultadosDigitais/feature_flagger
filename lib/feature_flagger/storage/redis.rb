require 'redis'
require 'redis-namespace'
require_relative './keys'

module FeatureFlagger
  module Storage
    class Redis
      DEFAULT_NAMESPACE    = :feature_flagger
      RESOURCE_PREFIX      = "_r".freeze
      MANIFEST_PREFIX      = "_m".freeze
      MANIFEST_KEY         = "manifest_file".freeze
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
        releases = @redis.sunion(resource_key, global_key)

        releases.select{ |release| release.start_with?(resource_name) }
      end

      def has_value?(key, value)
        @redis.sismember(key, value)
      end

      def count(key)
        @redis.scard(key)
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
        @redis.srem(global_key, feature_key)
        remove_feature_key_from_resources(feature_key)
      end

      def add_all(global_key, key)
        @redis.sadd(global_key, key)
        remove_feature_key_from_resources(key)
      end

      def all_values(key)
        @redis.smembers(key)
      end

      # DEPRECATED: this method will be removed from public api on v2.0 version.
      # use instead the feature_keys method.
      def search_keys(query)
        @redis.scan_each(match: query)
      end

      def feature_keys
        feature_keys = []

        @redis.scan_each(match: "*") do |key|
          # Reject keys related to feature responsible for return
          # released features for a given account.
          next if key.start_with?("#{RESOURCE_PREFIX}:")
          next if key.start_with?("#{MANIFEST_PREFIX}:")

          feature_keys << key
        end

        feature_keys
      end

      def synchronize_feature_and_resource
        FeatureFlagger::Storage::FeatureKeysMigration.new(
          @redis,
          FeatureFlagger.control,
        ).call
      end

      def read_manifest_backup
        @redis.get("#{MANIFEST_PREFIX}:#{MANIFEST_KEY}")
      end

      def write_manifest_backup(yaml_as_string)
        @redis.set("#{MANIFEST_PREFIX}:#{MANIFEST_KEY}", yaml_as_string)
      end

      private

      def resource_key(resource_name, resource_id)
        FeatureFlagger::Storage::Keys.resource_key(
          RESOURCE_PREFIX,
          resource_name,
          resource_id,
        )
      end

      def remove_feature_key_from_resources(feature_key)
        cursor = 0
        resource_name = feature_key.split(":").first

        loop do
          cursor, resource_ids = @redis.sscan(feature_key, cursor, count: SCAN_EACH_BATCH_SIZE)

          @redis.multi do |redis|
            resource_ids.each do |resource_id|
              key = resource_key(resource_name, resource_id)
              redis.srem(key, feature_key)
              redis.srem(feature_key, resource_id)
            end
          end

          break if cursor == "0"
        end
      end
    end
  end
end
