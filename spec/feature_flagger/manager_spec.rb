# frozen_string_literal: true

require 'spec_helper'
require 'benchmark'

module FeatureFlagger
  RSpec.describe Manager do
    describe 'detached_feature_keys' do
      let(:redis) { FakeRedis::Redis.new }
      let(:storage) { Storage::Redis.new(redis) }
      let(:resource_name) { 'other_feature_flagger_dummy_class' }
      let(:resource_id) { 0 }

      it 'returns all detached feature keys' do
        FeatureFlagger.configure do |config|
          config.storage = storage
        end

        FeatureFlagger.control.release('feature_a:feature_a_1:feature_a_1_1', resource_name, resource_id)
        FeatureFlagger.control.release('feature_a:feature_a_1:feature_a_1_2', resource_name, resource_id)
        FeatureFlagger.control.release('feature_a:feature_a_1:feature_a_1_3', resource_name, resource_id)
        FeatureFlagger.control.release('feature_b', resource_name, resource_id)
        FeatureFlagger.control.release('feature_d', resource_name, resource_id)

        filepath = File.expand_path('../fixtures/rollout_example.yml', __dir__)
        FeatureFlagger.config.yaml_filepath = filepath

        expect(described_class.detached_feature_keys(resource_name)).to include(
          'feature_a:feature_a_1:feature_a_1_3',
          'feature_d'
        )
      end
    end

    describe 'cleanup_detached' do
      context 'detached feature key' do
        let(:redis) { FakeRedis::Redis.new }
        let(:storage) { Storage::Redis.new(redis) }
        let(:feature_key) { 'feature_d' }
        let(:resource_name) { 'other_feature_flagger_dummy_class' }
        let(:resource_id) { 0 }

        before do
          FeatureFlagger.configure do |config|
            config.storage = storage
          end
          FeatureFlagger.control.release(feature_key, resource_name, resource_id)

          filepath = File.expand_path('../fixtures/rollout_example.yml', __dir__)
          FeatureFlagger.config.yaml_filepath = filepath
        end

        it 'cleanup key' do
          described_class.cleanup_detached(resource_name, feature_key)

          expect(described_class.detached_feature_keys(resource_name)).not_to include feature_key
        end
      end

      context 'mapped feature key' do
        before do
          filepath = File.expand_path('../fixtures/rollout_example.yml', __dir__)
          FeatureFlagger.config.yaml_filepath = filepath
        end

        it 'do not cleanup key' do
          expect do
            described_class.cleanup_detached(
              :feature_flagger_dummy_class, :email_marketing, :behavior_score
            )
          end.to raise_error('key is still mapped')
        end
      end
    end
  end
end
