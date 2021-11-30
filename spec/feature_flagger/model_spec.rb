require 'spec_helper'

module FeatureFlagger

  class DummyClass
    include FeatureFlagger::Model
    def id; 14 end
  end

  RSpec.describe Model do
    subject             { DummyClass.new }
    let(:key)           { [:email_marketing, :whitelabel] }
    let(:resolved_key)  { 'feature_flagger_dummy_class:email_marketing:whitelabel' }
    let(:control)       { FeatureFlagger.control }

    before do
      filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
      FeatureFlagger.config.manifest_source = filepath
    end

    describe '#release' do
      it 'calls Control#release with appropriated methods' do
        expect(control).to receive(:release).with(resolved_key, subject.id)
        subject.release(key)
      end
    end
    
    describe '#releases' do
      it 'calls Control#release with appropriated methods' do
        expect(control).to receive(:releases).with("feature_flagger_dummy_class", subject.id, {})
        subject.releases
      end
    end

    describe '#unrelease' do
      it 'calls Control#unrelease with appropriated methods' do
        expect(control).to receive(:unrelease).with(resolved_key, subject.id)
        subject.unrelease(key)
      end
    end

    describe '.released_id?' do
      context 'given a specific resource id' do
        let(:resource_id) { 10 }

        it 'calls Control#released? with appropriated methods' do
          expect(control).to receive(:released?).with(resolved_key, resource_id, {})
          DummyClass.released_id?(resource_id, key)
        end

        it 'passes down cache options to storage' do
          expect(control).to receive(:released?).with(resolved_key, resource_id, { skip_cache: true })
          DummyClass.released_id?(resource_id, key, skip_cache: true)
        end
      end
    end

    describe '.release_id' do
      context 'given a specific resource id' do
        let(:resource_id) { 10 }

        it 'calls Control#release with appropriated methods' do
          expect(control).to receive(:release).with(resolved_key, resource_id)
          DummyClass.release_id(resource_id, key)
        end
      end
    end

    describe '.unrelease_id' do
      context 'given a specific resource id' do
        let(:resource_id) { 20 }

        it 'calls Control#release with appropriated methods' do
          expect(control).to receive(:unrelease).with(resolved_key, resource_id)
          DummyClass.unrelease_id(resource_id, key)
        end
      end
    end

    describe '.all_released_ids_for' do
      it 'calls Control#resource_ids with appropriated methods' do
        expect(control).to receive(:resource_ids).with(resolved_key, {})
        DummyClass.all_released_ids_for(key)
      end

      it 'passes down cache options to storage' do
        expect(control).to receive(:resource_ids).with(resolved_key, { skip_cache: true})
        DummyClass.all_released_ids_for(key, skip_cache: true)
      end
    end

    describe '.release_to_all' do
      it 'calls Control#release_to_all with appropriated methods' do
        expect(control).to receive(:release_to_all).with(resolved_key)
        DummyClass.release_to_all(key)
      end
    end

    describe '.unrelease_to_all' do
      it 'calls Control#unrelease_to_all with appropriated methods' do
        expect(control).to receive(:unrelease_to_all).with(resolved_key)
        DummyClass.unrelease_to_all(key)
      end
    end

    describe '.released_features_to_all' do
      it 'calls Control#released_features_to_all with appropriated methods' do
        expect(control).to receive(:released_features_to_all)
        DummyClass.released_features_to_all
      end
    end

    describe '.released_to_all?' do
      it 'calls Control#released_to_all? with appropriated methods' do
        expect(control).to receive(:released_to_all?).with(resolved_key, {})
        DummyClass.released_to_all?(key)
      end
    end

    describe '.detached_feature_keys' do
      let(:redis) { FakeRedis::Redis.new }
      let(:storage) { Storage::Redis.new(redis) }

      before do
        FeatureFlagger.configure do |config|
          config.storage = storage
        end
        FeatureFlagger.control.release('feature_flagger_dummy_class:feature_a', 0)
        FeatureFlagger.control.release('feature_flagger_dummy_class:feature_b', 0)

        filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
        FeatureFlagger.config.manifest_source = filepath
      end

      it 'returns all detached feature keys' do
        expect(DummyClass.detached_feature_keys).to contain_exactly("feature_a","feature_b")
      end
    end

    describe '.cleanup_detached' do
      context "detached feature key" do
        let(:redis) { FakeRedis::Redis.new }
        let(:storage) { Storage::Redis.new(redis) }
        let(:feature_key) { 'feature_flagger_dummy_class:feature_a' }

        before do
          FeatureFlagger.configure do |config|
            config.storage = storage
          end
          FeatureFlagger.control.release(feature_key, 0)

          filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
          FeatureFlagger.config.manifest_source = filepath
        end

        it 'cleanup key' do
          DummyClass.cleanup_detached(:feature_a)
          expect(DummyClass.detached_feature_keys).not_to include "feature_a"
        end
      end

      context "mapped feature key" do
        it 'do not cleanup key' do
          expect {
            DummyClass.cleanup_detached(:email_marketing, :behavior_score)
          }.to raise_error("key is still mapped")
        end
      end
    end

    describe '.feature_flagger' do
      class CustomizedDummyClass
        include FeatureFlagger::Model

        feature_flagger do |config|
          config.identifier_field = :uuid
          config.entity_name = :account
        end

        def uuid
          'f11bc560-8ef9-40cf-909e-ebb1c6f41163'
        end
      end

      it 'expect to be using account entity name and uuid as field' do
        CustomizedDummyClass.new.release(:email_marketing, :behavior_score)

        expect(CustomizedDummyClass.all_released_ids_for(:email_marketing, :behavior_score)).to include(
          'f11bc560-8ef9-40cf-909e-ebb1c6f41163'
        )
      end
    end

  end
end
