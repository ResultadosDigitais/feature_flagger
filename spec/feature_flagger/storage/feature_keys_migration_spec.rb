
# frozen_string_literal: true

require 'spec_helper'
require 'feature_flagger/storage/feature_keys_migration'

RSpec.describe FeatureFlagger::Storage::FeatureKeysMigration do
  subject(:migrator) { described_class.new(from_redis, to_control) }

  let(:from_redis) { FakeRedis::Redis.new }
  let(:to_redis)   { FakeRedis::Redis.new }
  let(:to_control) { FeatureFlagger::Control.new(FeatureFlagger::Storage::Redis.new(to_redis)) }
  let(:global_key) { FeatureFlagger::Control::RELEASED_FEATURES }

  before do
    from_redis.select(1)
    to_redis.select(2)

    filepath = File.expand_path('../fixtures/rollout_example.yml', __dir__)
    FeatureFlagger.config.yaml_filepath = filepath
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
        from_redis.sadd('feature_flagger_dummy_class:email_marketing:behavior_score', 42)
        from_redis.sadd('feature_flagger_dummy_class:email_marketing:whitelabel', 42)
        from_redis.sadd('feature_flagger_dummy_class:email_marketing:whitelabel', 1)
        from_redis.sadd(global_key, 'other_feature_flagger_dummy_class:feature_c:feature_c_1')
        from_redis.sadd(global_key, 'other_feature_flagger_dummy_class:feature_c:feature_c_2')
        from_redis.sadd(global_key, 'account')

        migrator.call
      end

      it 'migrates feature keys to the new format' do
        expect(to_control.released?('feature_flagger_dummy_class:email_marketing:behavior_score', 42)).to be_truthy
        expect(to_control.released?('feature_flagger_dummy_class:email_marketing:whitelabel', 42)).to be_truthy
        expect(to_control.released?('feature_flagger_dummy_class:email_marketing:whitelabel', 1)).to be_truthy
      end

      it 'migrates all released feature keys to the new format' do
        expect(to_control.released_to_all?('other_feature_flagger_dummy_class:feature_c:feature_c_2')).to be_truthy
        expect(to_control.released_to_all?('other_feature_flagger_dummy_class:feature_c:feature_c_1')).to be_truthy
      end
    end

    context 'when there are keys in both formats' do
      before do
        from_redis.sadd('feature_flagger_dummy_class:email_marketing:behavior_score', 42)
        from_redis.sadd('feature_flagger_dummy_class:email_marketing:whitelabel', 42)
        from_redis.sadd('feature_flagger_dummy_class:email_marketing:whitelabel', 1)
        from_redis.sadd(global_key, 'feature_flagger_dummy_class:email_marketing:whitelabel')

        to_control.release('other_feature_flagger_dummy_class:feature_b', 42)
        to_control.release_to_all('other_feature_flagger_dummy_class:feature_c:feature_c_1')

        migrator.call
      end

      it 'migrates feature keys to the new format' do
        expect(to_control.released?('feature_flagger_dummy_class:email_marketing:behavior_score', 42)).to be_truthy
        expect(to_control.released?('feature_flagger_dummy_class:email_marketing:whitelabel', 42)).to be_truthy
        expect(to_control.released?('feature_flagger_dummy_class:email_marketing:whitelabel', 1)).to be_truthy
        expect(to_control.released?('other_feature_flagger_dummy_class:feature_b', 42)).to be_truthy
      end

      it 'migrates all released feature keys to the new format ' do
        expect(to_control.released_to_all?('feature_flagger_dummy_class:email_marketing:whitelabel')).to be_truthy
        expect(to_control.released_to_all?('other_feature_flagger_dummy_class:feature_c:feature_c_1')).to be_truthy
      end
    end
  end
end