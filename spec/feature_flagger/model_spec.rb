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
      FeatureFlagger.config.yaml_filepath = filepath
    end

    describe '#release' do
      it 'calls Control#release with appropriated methods' do
        expect(control).to receive(:release).with(resolved_key, subject.id)
        subject.release(key)
      end
    end

    describe '#rollout?' do
      it 'calls Control#rollout? with appropriated methods' do
        expect(control).to receive(:rollout?).with(resolved_key, subject.id)
        subject.rollout?(key)
      end
    end

    describe '#released_keys' do
      it 'calls Control#released_keys with appropriated methods' do
        childs_keys = %w(feature_flagger_dummy_class:email_marketing:behavior_score
                    feature_flagger_dummy_class:email_marketing:whitelabel)

        expect(control).to receive(:released_keys).with(childs_keys, subject.id)
        subject.released_keys(:email_marketing)
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

        it 'calls Control#rollout? with appropriated methods' do
          expect(control).to receive(:rollout?).with(resolved_key, resource_id)
          DummyClass.released_id?(resource_id, key)
        end
      end
    end

    describe '.all_released_ids_for' do
      it 'calls Control#resource_ids with appropriated methods' do
        expect(control).to receive(:resource_ids).with(resolved_key)
        DummyClass.all_released_ids_for(key)
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
      it 'calls Control#resource_ids with appropriated methods' do
        expect(control).to receive(:released_features_to_all)
        DummyClass.released_features_to_all
      end
    end
  end
end
