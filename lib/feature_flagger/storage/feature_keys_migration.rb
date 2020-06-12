# frozen_string_literal: true

module FeatureFlagger
  module Storage
    class FeatureKeysMigration
      def initialize(from_redis, to_control)
        @from_redis = from_redis
        @to_control = to_control
      end

      def call
        @from_redis.keys('*').map { |key| migrate_key(key) }.flatten
      end

      private

      def migrate_key(key)
        return migrate_release_to_all(key) if feature_released_to_all?(key)

        migrate_release(key)
      end

      def migrate_release_to_all(key)
        features = @from_redis.smembers(key)

        features.map do |feature|
          resource_name, feature_key = KeyDecomposer.decompose(feature)
          feature = Feature.new(feature_key, resource_name)

          @to_control.release_to_all(feature.key, resource_name)
        rescue KeyNotFoundError => _e
          next
        end
      end

      def feature_released_to_all?(key)
        FeatureFlagger::Control::RELEASED_FEATURES == key
      end

      def migrate_release(key)
        return false if key =~ /(\d+).*/

        resource_ids = @from_redis.smembers(key)

        resource_name, feature_key = KeyDecomposer.decompose(key)
        feature = Feature.new(feature_key, resource_name)

        @to_control.release(feature.key, resource_name, resource_ids)
      rescue KeyNotFoundError => _e
        return
      end
    end
  end
end
