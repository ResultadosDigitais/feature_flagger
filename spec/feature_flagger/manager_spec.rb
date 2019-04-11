require 'spec_helper'

module FeatureFlagger
  RSpec.describe Manager do
    describe 'mapped_feature_keys' do
      let(:expected_features) do
        [
          "feature_flagger_dummy_class:email_marketing:behavior_score",
          "feature_flagger_dummy_class:email_marketing:whitelabel",
          "other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_1",
          "other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_2",
          "other_feature_flagger_dummy_class:feature_b",
          "other_feature_flagger_dummy_class:feature_c:feature_c_1",
          "other_feature_flagger_dummy_class:feature_c:feature_c_2",
          "other_feature_flagger_dummy_class:feature_c:feature_c_3:feature_c_3_1:feature_c_3_1_1"
        ]
      end

      before do
        filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
        FeatureFlagger.config.yaml_filepath = filepath
      end

      it 'returns all mapped features keys' do
        expect(described_class.mapped_feature_keys).to eq expected_features
      end
    end

    describe 'detached_feature_keys' do
      let(:redis) { FakeRedis::Redis.new }
      let(:storage) { Storage::Redis.new(redis) }
      let(:feature_a_1_3) { "other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_3" }
      let(:feature_d) { "other_feature_flagger_dummy_class:feature_d" }

      before do
        FeatureFlagger.configure do |config|
          config.storage = storage
        end
        FeatureFlagger.control.release("other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_1", 0)
        FeatureFlagger.control.release("other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_2", 0)
        FeatureFlagger.control.release("other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_3", 0)
        FeatureFlagger.control.release("other_feature_flagger_dummy_class:feature_b", 0)
        FeatureFlagger.control.release("other_feature_flagger_dummy_class:feature_d", 0)

        filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
        FeatureFlagger.config.yaml_filepath = filepath
      end

      it 'returns all detached feature keys' do
        expect(described_class.detached_feature_keys).to include feature_a_1_3, feature_d
      end
    end

    describe 'remove_feature_key' do
      let(:redis) { FakeRedis::Redis.new }
      let(:storage) { Storage::Redis.new(redis) }
      let(:feature_key) { "other_feature_flagger_dummy_class:feature_d" }

      before do
        FeatureFlagger.configure do |config|
          config.storage = storage
        end
        FeatureFlagger.control.release(feature_key, 0)

        filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
        FeatureFlagger.config.yaml_filepath = filepath
      end

      it 'remove key' do
        described_class.remove_feature_key(feature_key)
        expect(described_class.detached_feature_keys).not_to include feature_key
      end
    end
  end
end
