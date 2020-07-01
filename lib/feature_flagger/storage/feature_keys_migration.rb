# frozen_string_literal: true

module FeatureFlagger
    module Storage
      class FeatureKeysMigration
        ONLY_DIGITS = /\A(\d+).*\z/.freeze

        def initialize(from_redis, to_control)
          @from_redis = from_redis
          @to_control = to_control
        end

        # call migrates features key from the old fashioned to the new
        # format.
        #
        # It must replicate feature keys with changes:
        #
        # from "avenue:traffic_lights" => 42
        # to   "avenue:42" => traffic_lights
        def call
          @from_redis.scan_each(match: "*", count: FeatureFlagger::Storage::Redis::SCAN_EACH_BATCH_SIZE) do |redis_key|
            # filter out resource_keys
            next if redis_key.start_with?("#{FeatureFlagger::Storage::Redis::RESOURCE_PREFIX}:")

            migrate_key(redis_key)
          end
        end

        private

        def migrate_key(key)
          return migrate_release_to_all(key) if feature_released_to_all?(key)

          migrate_release(key)
        end

        def migrate_release_to_all(key)
          features = @from_redis.smembers(key)

          features.each do |feature_key|
            @to_control.release_to_all(feature_key)
          rescue KeyNotFoundError => _e
            next
          end
        end

        def feature_released_to_all?(key)
          FeatureFlagger::Control::RELEASED_FEATURES == key
        end

        def migrate_release(key)
          resource_ids = @from_redis.smembers(key)

          @to_control.release(key, resource_ids)
        rescue KeyNotFoundError => _e
          return
        end
      end
    end
  end