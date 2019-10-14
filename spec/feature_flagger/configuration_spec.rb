require 'spec_helper'

module FeatureFlagger
  RSpec.describe Configuration do
    describe '.storage' do
      let(:configuration) { described_class.new }

      context 'no storage set' do
        it 'returns a Redis storage by default' do
          expect(configuration.storage).to be_a(FeatureFlagger::Storage::Redis)
        end
      end

      context 'storage set' do
        let(:storage) { double('storage') }

        before { configuration.storage = storage }

        it 'returns storage' do
          expect(configuration.storage).to eq storage
        end
      end
    end

    describe 'mapped_feature_keys' do
      let(:configuration) { described_class.new }

      before do
        filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
        configuration.yaml_filepath = filepath
      end

      context 'without resource name' do
        it 'returns all mapped features keys' do
          expect(configuration.mapped_feature_keys).to contain_exactly(
            'feature_flagger_dummy_class:email_marketing:behavior_score',
            'feature_flagger_dummy_class:email_marketing:whitelabel',
            'other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_1',
            'other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_2',
            'other_feature_flagger_dummy_class:feature_b',
            'other_feature_flagger_dummy_class:feature_c:feature_c_1',
            'other_feature_flagger_dummy_class:feature_c:feature_c_2',
            'other_feature_flagger_dummy_class:feature_c:feature_c_3:feature_c_3_1:feature_c_3_1_1',
            'account:email_marketing:behavior_score'
          )
        end
      end

      context 'with resource name' do
        it 'returns mapped features keys for feature_flagger_dummy_class resource' do
          expect(configuration.mapped_feature_keys('feature_flagger_dummy_class')).to contain_exactly(
            'feature_flagger_dummy_class:email_marketing:behavior_score',
            'feature_flagger_dummy_class:email_marketing:whitelabel'
          )
        end
      end
    end
  end
end
