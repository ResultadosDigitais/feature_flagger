require 'spec_helper'
require 'benchmark'

module FeatureFlagger
  RSpec.describe Manager do
    describe 'detached_feature_keys' do
      let(:redis) { FakeRedis::Redis.new }
      let(:storage) { Storage::Redis.new(redis) }
      let(:resolved_resource_key) { 'other_feature_flagger_dummy_class:42'  }

      before do
        FeatureFlagger.configure do |config|
          config.storage = storage
        end
        FeatureFlagger.control.release(
          'other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_1', 0, resolved_resource_key)
        FeatureFlagger.control.release(
          'other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_2', 0, resolved_resource_key)
        FeatureFlagger.control.release(
          'other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_3', 0, resolved_resource_key)
        FeatureFlagger.control.release('other_feature_flagger_dummy_class:feature_b', 0, resolved_resource_key)
        FeatureFlagger.control.release('other_feature_flagger_dummy_class:feature_d', 0, resolved_resource_key)

        filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
        FeatureFlagger.config.yaml_filepath = filepath
      end

      it 'returns all detached feature keys' do
        expect(described_class.detached_feature_keys).to include(
          'other_feature_flagger_dummy_class:feature_a:feature_a_1:feature_a_1_3',
          'other_feature_flagger_dummy_class:feature_d'
        )
      end
    end

    describe 'cleanup_detached' do
      context "detached feature key" do
        let(:redis) { FakeRedis::Redis.new }
        let(:storage) { Storage::Redis.new(redis) }
        let(:resolved_resource_key) { 'other_feature_flagger_dummy_class:42'  }
        let(:feature_key) { 'other_feature_flagger_dummy_class:feature_d' }

        before do
          FeatureFlagger.configure do |config|
            config.storage = storage
          end
          FeatureFlagger.control.release(feature_key, 0, resolved_resource_key)

          filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
          FeatureFlagger.config.yaml_filepath = filepath
        end

        it 'cleanup key' do
          described_class.cleanup_detached(
            :other_feature_flagger_dummy_class, :feature_d
          )
          expect(described_class.detached_feature_keys).not_to include feature_key
        end
      end

      context "mapped feature key" do
        before do
          filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
          FeatureFlagger.config.yaml_filepath = filepath
        end

        it 'do not cleanup key' do
          expect {
            described_class.cleanup_detached(
              :feature_flagger_dummy_class, :email_marketing, :behavior_score
            )
          }.to raise_error("key is still mapped")
        end
      end
    end

    describe 'how fast can I count models with feature', :wip do
      let(:redis) { FakeRedis::Redis.new }
      let(:storage) { Storage::Redis.new(redis) }

      before do
        FeatureFlagger.configure do |config|
          config.storage = storage
        end
      end

      it 'returns all detached feature keys' do
        # Criar uma lista de 10000 features
        # Criar 10 models
        filepath = File.expand_path('../fixtures/features_performance.yaml', __dir__)
        FeatureFlagger.config.yaml_filepath = filepath

        models = (0..9).map{ |i| "model_#{i}" }
        features = (0...1000).map{ |f| "feature_#{f}" }

        # Liberar Aleatoriamente Features p/ models
        models.each do |model|
          features.each do |feature|
            FeatureFlagger.control.release("#{model}:#{feature}",  (0..rand(10_000)).to_a)
          end
        end

        puts Benchmark.measure {
          # Bench: Quantas models tem a feature
          puts FeatureFlagger.control.resource_ids("#{models.first}:#{features.first}").count
        }

        # Bench: Quantas features tem a model

        expect(true).to eq(true)
      end
    end
  end
end
