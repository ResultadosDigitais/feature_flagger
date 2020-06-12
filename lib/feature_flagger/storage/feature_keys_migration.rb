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
          resource_name, feature_key = feature.split(':')
          @to_control.release_to_all(feature_key, resource_name)
        end
      end

      def feature_released_to_all?(key)
        FeatureFlagger::Control::RELEASED_FEATURES == key
      end

      def migrate_release(key)
        return false if key =~ /(\d+).*/

        resource_ids = @from_redis.smembers(key)

        decomposed_key = key.split(':')
        resource_name = decomposed_key.shift
        feature_key = decomposed_key.join(':')

        @to_control.release(feature_key, resource_name, resource_ids)
      end
    end
  end
end
