# frozen_string_literal: true

require 'spec_helper'

module FeatureFlagger
  RSpec.describe FeatureKeysMigration do

    describe '.call' do
      context 'when there are keys in the old format' do
        subject(:migrator) { described_class.new(from_redis, to_control) }

        let(:from_redis)   { FakeRedis::Redis.new }

        let(:to_redis)   { FakeRedis::Redis.new }
        let(:to_control) { Control.new(Storage::Redis.new(to_redis)) }

        it 'migrates the keys to the new format' do
          # old_format: { class_name:feature_key => [id] }
          # new_format: { class_name:id => [feature_key] }
          feature_key = 'traffic_light'
          id = 42
          class_name = 'avenue'

          # Setup old key format
          from_redis.select(1)
          from_redis.sadd("#{class_name}:#{feature_key}", id)

          # Setup second redis
          to_redis.select(2)

          # Run the migration
          migrator.call

          expect(to_control.released?(feature_key, class_name, id)).to be_truthy
        end
      end

      context 'when there are keys in the new format' do
        context 'when there are keys in the old format' do
          subject(:migrator) { described_class.new(redis, control) }

          let(:redis)   { FakeRedis::Redis.new }
          let(:control) { Control.new(Storage::Redis.new(redis)) }


          it 'uses the old format as source of truth' do
            # old_format: { class_name:feature_key => [id] }
            # new_format: { class_name:id => [feature_key] }
            feature_key = 'traffic_light'
            id = 42
            class_name = 'avenue'

            # Setup old key format
            redis.sadd("#{class_name}:#{feature_key}", id)
            redis.sadd(FeatureFlagger::Control::RELEASED_FEATURES, "#{class_name}:global_released_feature")

            # Also setup new keys
            control.release(feature_key, class_name, 2)
            control.release_to_all('another_feature', class_name)

            # Run the migration
            migrator.call

            expect(control.released?(feature_key, class_name, id)).to be_truthy
            expect(control.released?(feature_key, class_name, 2)).to be_truthy
            expect(control.released?('another_feature', class_name, id)).to be_truthy
            expect(control.released?('global_released_feature', class_name, id)).to be_truthy
          end
        end
      end
    end
  end
end
