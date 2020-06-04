# frozen_string_literal: true

require 'spec_helper'

module FeatureFlagger
  module Storage
    RSpec.describe FeatureKeysMigration do
      subject(:migrator) { described_class.new(from_redis, to_control) }

      let(:from_redis) { FakeRedis::Redis.new }
      let(:to_redis)   { FakeRedis::Redis.new }
      let(:to_control) { Control.new(Storage::Redis.new(to_redis)) }
      let(:global_key) { FeatureFlagger::Control::RELEASED_FEATURES }

      before do
        from_redis.select(1)
        to_redis.select(2)
      end

      # This method migrates features key from the old fashioned to the new
      # format.
      #
      # It must convert feature keys with changes:
      # 
      # from "avenue:traffic_lights" => 42
      # to   "avenue:42" => traffic_lights
      describe '.call' do
        context 'when there are keys in the old format' do
          before do
            from_redis.sadd('avenue:traffic_light', 42)
            from_redis.sadd('avenue:hydrant', 42)
            from_redis.sadd('avenue:hydrant', 1)
            from_redis.sadd(global_key, 'avenue:crosswalk')
            from_redis.sadd(global_key, 'avenue:streetlight')

            migrator.call
          end

          it 'migrates feature keys to the new format' do
            expect(to_control.released?('traffic_light', 'avenue', 42)).to be_truthy
            expect(to_control.released?('hydrant', 'avenue', 42)).to be_truthy
            expect(to_control.released?('hydrant', 'avenue', 1)).to be_truthy
          end

          it 'migrates all released feature keys to the new format ' do
            expect(to_control.released_to_all?('crosswalk', 'avenue')).to be_truthy
            expect(to_control.released_to_all?('streetlight', 'avenue')).to be_truthy
          end
        end

        context 'when there are keys in both formats' do
          before do
            from_redis.sadd('avenue:traffic_light', 42)
            from_redis.sadd('avenue:hydrant', 42)
            from_redis.sadd('avenue:hydrant', 1)
            from_redis.sadd(global_key, 'avenue:crosswalk')
            from_redis.sadd(global_key, 'avenue:streetlight')

            to_control.release('payphone', 'avenue', 42)
            to_control.release_to_all('cameras', 'avenue')

            migrator.call
          end

          it 'migrates feature keys to the new format' do
            expect(to_control.released?('traffic_light', 'avenue', 42)).to be_truthy
            expect(to_control.released?('hydrant', 'avenue', 42)).to be_truthy
            expect(to_control.released?('hydrant', 'avenue', 1)).to be_truthy
            expect(to_control.released?('payphone', 'avenue', 42)).to be_truthy
          end

          it 'migrates all released feature keys to the new format ' do
            expect(to_control.released_to_all?('crosswalk', 'avenue')).to be_truthy
            expect(to_control.released_to_all?('streetlight', 'avenue')).to be_truthy
            expect(to_control.released_to_all?('cameras', 'avenue')).to be_truthy
          end
        end
      end
    end
  end
end
