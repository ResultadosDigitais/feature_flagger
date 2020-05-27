require 'spec_helper'

module FeatureFlagger
  RSpec.describe FeatureKeysMigration do
    subject(:migrator) { described_class.new(from_redis, to_control) }

    let(:from_redis)   { FakeRedis::Redis.new }

    let(:to_redis)   { FakeRedis::Redis.new }
    let(:to_control) { Control.new(Storage::Redis.new(to_redis)) }

    describe '.call' do
      context 'when there are keys in the old format' do
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
          it "uses the old format as source of truth"
        end
      end
    end
  end
end
