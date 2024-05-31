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

    describe '.cache_store' do
      let(:configuration) { described_class.new }

      context 'no cache_store set' do
        it 'returns nil by default' do
          expect(configuration.cache_store).to be_nil
        end
      end

      context 'cache_store set to :null_store when explicit set to nil' do
        it 'returns an ActiveSupport::Cache::NullStore instance' do
          configuration.cache_store = nil
          expect(configuration.cache_store).to be_an(ActiveSupport::Cache::NullStore)
        end
      end

      context 'cache_store set to :memory_store' do
        it 'returns an ActiveSupport::Cache::MemoryStore instance' do
          configuration.cache_store = :memory_store
          expect(configuration.cache_store).to be_an(ActiveSupport::Cache::MemoryStore)
        end

        it 'allows custom params' do
          configuration.cache_store = :memory_store, { expires_in: 100 }
          expect(configuration.cache_store.options[:expires_in]).to eq(100)
        end
      end
    end

    describe 'mapped_feature_keys' do
      let(:configuration) { described_class.new }

      before do
        yaml_path = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
        allow(configuration).to receive(:info).and_return(YAML.load_file(yaml_path))
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

    describe '.notifier_callback' do
      let(:configuration) { described_class.new }

      context 'no notifier_callback set' do
        it 'returns nil if no callback is set' do
          expect(configuration.notifier_callback).to be_nil
        end
      end
    end
  end
end
