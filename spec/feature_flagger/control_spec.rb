require 'spec_helper'

module FeatureFlagger
  RSpec.describe Control do
    let(:redis) { FakeRedis::Redis.new }
    let(:storage) { Storage::Redis.new(redis) }
    let(:control) { Control.new(storage) }
    let(:key)         { 'key' }
    let(:resource_id) { 'resource_id' }

    before do
      redis.flushdb
    end

    describe '#released?' do
      let(:result) { control.released?(key, resource_id) }

      context 'when resource entity id has no access to release_key' do
        it { expect(result).to be_falsey }

        context 'and a feature is release to all' do
          before { storage.add(FeatureFlagger::Control::RELEASED_FEATURES, key) }
          it { expect(result).to be_truthy }
        end
      end

      context 'when resource entity id has access to release_key' do
        before { storage.add(key, resource_id) }
        it { expect(result).to be_truthy }

        context 'and a feature is release to all' do
          before { storage.add(FeatureFlagger::Control::RELEASED_FEATURES, key) }
          it { expect(result).to be_truthy }
        end
      end
    end

    describe '#release' do
      it 'adds resource_id to storage' do
        control.release(key, resource_id)
        expect(storage).to have_value(key, resource_id)
      end
    end

    describe '#release_to_all' do
      it 'adds feature_key to storage' do
        storage.add(key, 1)
        control.release_to_all(key)
        expect(storage).not_to have_value(key, 1)
        expect(storage).to have_value(FeatureFlagger::Control::RELEASED_FEATURES, key)
      end
    end

    describe '#unrelease' do
      it 'removes resource_id from storage' do
        storage.add(key, resource_id)
        control.unrelease(key, resource_id)
        expect(storage).not_to have_value(key, resource_id)
      end
    end

    describe '#unrelease_to_all' do
      it 'removes feature_key to storage' do
        storage.add(FeatureFlagger::Control::RELEASED_FEATURES, key)
        control.unrelease_to_all(key)
        expect(storage).not_to have_value(FeatureFlagger::Control::RELEASED_FEATURES, key)
      end

      it 'removes added resources' do
        storage.add(key, 1)
        control.unrelease_to_all(key)
        expect(storage).not_to have_value(key, 1)
        expect(storage).not_to have_value(FeatureFlagger::Control::RELEASED_FEATURES, key)
      end
    end

    describe '#resource_ids' do
      subject { control.resource_ids(key) }

      it 'returns all the values to given key' do
        control.release(key, 1)
        control.release(key, 2)
        control.release(key, 15)
        is_expected.to match_array %w(1 2 15)
      end
    end

    describe '#released_features_to_all' do
      subject { control.released_features_to_all }

      it 'returns all the values to given features' do
        control.release(FeatureFlagger::Control::RELEASED_FEATURES, 'feature::name1')
        control.release(FeatureFlagger::Control::RELEASED_FEATURES, 'feature::name2')
        control.release(FeatureFlagger::Control::RELEASED_FEATURES, 'feature::name15')
        is_expected.to match_array %w(feature::name1 feature::name2 feature::name15)
      end
    end
  end
end
