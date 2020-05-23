require 'spec_helper'

module FeatureFlagger
  RSpec.describe Control do
    let(:redis)         { FakeRedis::Redis.new }
    let(:storage)       { Storage::Redis.new(redis) }
    let(:control)       { Control.new(storage) }
    let(:key)           { 'key' }
    let(:resource_id)   { 'resource_id' }
    let(:resource_name) { 'avenue' }
    let(:resource_key)  { "#{resource_name}:#{resource_id}" }

    before do
      redis.flushdb
    end

    describe '#released?' do
      let(:result) { control.released?(key, resource_id) }

      context 'when resource entity id has no access to release_key' do
        it { expect(result).to be_falsey }

        context 'and a feature is release to all' do
          before { storage.add_all(FeatureFlagger::Control::RELEASED_FEATURES, key) }

          it { expect(result).to be_truthy }
        end
      end

      context 'when resource entity id has access to release_key' do
        before { storage.add(key, resource_id, resource_key) }

        it { expect(result).to be_truthy }

        context 'and a feature is release to all' do
          before { storage.add_all(FeatureFlagger::Control::RELEASED_FEATURES, key) }

          it { expect(result).to be_truthy }
        end
      end
    end

    describe '#release' do
      it 'adds resource_id to storage' do
        control.release(key, resource_id, resource_name)
        expect(storage).to have_value(key, resource_id)
        expect(storage).to have_value(resource_key, key)
      end
    end

    describe '#release_to_all' do
      it 'adds feature_key to storage' do
        storage.add(key, 1, resource_name)
        control.release_to_all(key)
        expect(storage).not_to have_value(key, 1)
        expect(storage).to have_value(FeatureFlagger::Control::RELEASED_FEATURES, key)
      end
    end

    describe '#unrelease' do
      it 'removes resource_id from storage' do
        storage.add(key, resource_id, resource_name)
        control.unrelease(key, resource_id, resource_name)
        expect(storage).not_to have_value(key, resource_id)
        expect(storage).not_to have_value(resource_key, key)
      end
    end

    describe '#unrelease_to_all' do
      it 'removes feature_key to storage' do
        storage.add_all(FeatureFlagger::Control::RELEASED_FEATURES, key)
        control.unrelease_to_all(key)
        expect(storage).not_to have_value(FeatureFlagger::Control::RELEASED_FEATURES, key)
      end

      it 'removes added resources' do
        storage.add(key, 1, resource_name)
        control.unrelease_to_all(key)
        expect(storage).not_to have_value(key, 1)
        expect(storage).not_to have_value(FeatureFlagger::Control::RELEASED_FEATURES, key)
      end
    end

    describe '#resource_ids' do
      subject { control.resource_ids(key) }

      it 'returns all the values to given key' do
        control.release(key, 1, resource_name)
        control.release(key, 2, resource_name)
        control.release(key, 15, resource_name)
        expect(subject).to match_array %w[1 2 15]
      end
    end

    describe '#released_features_to_all' do
      subject { control.released_features_to_all }

      it 'returns all the values to given features' do
        control.release(FeatureFlagger::Control::RELEASED_FEATURES, 'feature::name1', resource_name)
        control.release(FeatureFlagger::Control::RELEASED_FEATURES, 'feature::name2', resource_name)
        control.release(FeatureFlagger::Control::RELEASED_FEATURES, 'feature::name15', resource_name)
        expect(subject).to match_array %w[feature::name1 feature::name2 feature::name15]
      end
    end

    describe '#released_to_all?' do
      let(:result) { control.released_to_all?(key) }

      context 'when feature was not released to all' do
        before { storage.remove(FeatureFlagger::Control::RELEASED_FEATURES, key, resource_name) }

        it { expect(result).to be_falsey }
      end

      context 'when feature was released to all' do
        before { storage.add(FeatureFlagger::Control::RELEASED_FEATURES, key, resource_name) }

        it { expect(result).to be_truthy }
      end
    end

    describe '#search_keys' do
      before do
        storage.add('namespace:1', 1, resource_name)
        storage.add('namespace:2', 2, resource_name)
        storage.add('exclusive', 3, resource_name)
      end

      context 'without matching result' do
        it { expect(control.search_keys('invalid').to_a).to be_empty }
      end

      context 'with matching results' do
        it { expect(control.search_keys("*ame*pac*").to_a).to contain_exactly('namespace:1', 'namespace:2') }
      end
    end
  end
end
