# frozen_string_literal: true

require 'spec_helper'
require 'feature_flagger/storage/feature_keys_migration'

RSpec.describe FeatureFlagger::Storage::FeatureKeysMigration do
  subject(:migrator) { described_class.new(redis, control) }

  let(:redis) { FakeRedis::Redis.new }
  let(:control) { FeatureFlagger::Control.new(FeatureFlagger::Storage::Redis.new(redis)) }
  let(:global_key) { FeatureFlagger::Control::RELEASED_FEATURES }

  before do
    filepath = File.expand_path('../fixtures/rollout_example.yml', __dir__)
    FeatureFlagger.config.yaml_filepath = filepath
  end

  describe '.call' do
    context 'when there are keys in the old format' do
      before do
        redis.sadd('feature_flagger_dummy_class:email_marketing:behavior_score', 42)
        redis.sadd('feature_flagger_dummy_class:email_marketing:whitelabel', 42)
        redis.sadd('feature_flagger_dummy_class:email_marketing:whitelabel', 1)
        redis.sadd(global_key, 'other_feature_flagger_dummy_class:feature_c:feature_c_1')
        redis.sadd(global_key, 'other_feature_flagger_dummy_class:feature_c:feature_c_2')
        redis.sadd(global_key, 'account')

        migrator.call
      end

      it 'migrates feature keys to the new format' do
        expect(control.released?('feature_flagger_dummy_class:email_marketing:behavior_score', 42)).to be_truthy
        expect(control.released?('feature_flagger_dummy_class:email_marketing:whitelabel', 42)).to be_truthy
        expect(control.released?('feature_flagger_dummy_class:email_marketing:whitelabel', 1)).to be_truthy
      end

      it 'migrates all released feature keys to the new format' do
        expect(control.released_to_all?('other_feature_flagger_dummy_class:feature_c:feature_c_2')).to be_truthy
        expect(control.released_to_all?('other_feature_flagger_dummy_class:feature_c:feature_c_1')).to be_truthy
      end
    end

    context 'when there are keys in both formats' do
      before do
        redis.sadd('feature_flagger_dummy_class:email_marketing:behavior_score', 42)
        redis.sadd('feature_flagger_dummy_class:email_marketing:whitelabel', 42)
        redis.sadd('feature_flagger_dummy_class:email_marketing:whitelabel', 1)
        redis.sadd(global_key, 'feature_flagger_dummy_class:email_marketing:global_whitelabel')

        control.release('other_feature_flagger_dummy_class:feature_b', 42)
        control.release_to_all('other_feature_flagger_dummy_class:feature_c:feature_c_1')

        migrator.call
      end

      it 'migrates feature keys to the new format' do
        expect(control.released?('feature_flagger_dummy_class:email_marketing:behavior_score', 42)).to be_truthy
        expect(control.released?('feature_flagger_dummy_class:email_marketing:whitelabel', 42)).to be_truthy
        expect(control.released?('feature_flagger_dummy_class:email_marketing:whitelabel', 1)).to be_truthy
        expect(control.released?('other_feature_flagger_dummy_class:feature_b', 42)).to be_truthy

        expect(control.releases('feature_flagger_dummy_class', 1)).to match_array(
          [
            'feature_flagger_dummy_class:email_marketing:whitelabel',
            'feature_flagger_dummy_class:email_marketing:global_whitelabel'
          ]
        )
      end

      it 'does not migrate internal keys' do
        expect(redis.keys.count).to eq(7)
      end

      it 'migrates all released feature keys to the new format ' do
        expect(control.released_to_all?('feature_flagger_dummy_class:email_marketing:global_whitelabel')).to be_truthy
        expect(control.released_to_all?('other_feature_flagger_dummy_class:feature_c:feature_c_1')).to be_truthy
      end
    end
  end
end
