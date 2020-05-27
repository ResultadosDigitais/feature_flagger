require 'spec_helper'

module FeatureFlagger
  RSpec.describe Control do
    let(:redis)         { FakeRedis::Redis.new }
    let(:storage)       { Storage::Redis.new(redis) }
    let(:control)       { Control.new(storage) }
    let(:feature_key)   { 'key' }
    let(:resource_id)   { 'resource_id' }
    let(:resource_name) { 'avenue' }

    before do
      redis.flushdb
    end

    describe '#released?' do
      let(:result) { control.released?(feature_key, resource_name, resource_id) }

      context 'when resource entity id has no access to feature key' do
        it { expect(result).to be_falsey }

        context 'when a feature is released to all' do
          before { control.release_to_all(feature_key, resource_name) }

          it { expect(result).to be_truthy }
        end
      end

      context 'when resource entity id has access to feature key' do
        before { control.release(feature_key, resource_name, resource_id) }

        it { expect(result).to be_truthy }

        context 'when a feature is release to all' do
          before { control.release_to_all(feature_key, resource_name) }

          it { expect(result).to be_truthy }
        end
      end
    end

    describe '#release' do
      context 'when resource_id is an Array' do
        it 'adds all the ids to storage' do
          resource_ids = [resource_id, 'another_resource_id']
          control.release(feature_key, resource_name, resource_ids)

          expect(control.resource_ids(feature_key, resource_name)).to match_array(resource_ids)
        end
      end

      it 'adds resource_id to storage' do
        control.release(feature_key, resource_name, resource_id)

        expect(storage).to have_value(feature_key, resource_name, resource_id)
      end
    end

    describe '#release_to_all' do
      it 'adds feature_key to storage' do
        control.release_to_all(feature_key, resource_name)

        expect(control.released?(feature_key, resource_name, 1)).to be_truthy
        expect(control.all_feature_keys(resource_name, 1)).to eq([feature_key])
      end
    end

    describe '#unrelease' do
      it 'removes resource_id from storage' do
        control.release(feature_key, resource_name, resource_id)
        expect(control.released?(feature_key, resource_name, resource_id)).to be_truthy

        control.unrelease(feature_key, resource_name, resource_id)

        expect(control.released?(feature_key, resource_name, resource_id)).to be_falsey
      end
    end

    describe '#unrelease_to_all' do
      it 'removes feature_key from storage' do
        control.release_to_all(feature_key, resource_name)
        expect(control.released?(feature_key, resource_name, resource_id)).to be_truthy

        control.unrelease_to_all(feature_key, resource_name)

        expect(control.released?(feature_key, resource_name, resource_id)).to be_falsey
      end

      it 'removes added resources' do
        control.release(feature_key, resource_name, 1)

        control.unrelease_to_all(feature_key, resource_name)

        expect(control.released?(feature_key, resource_name, 1)).to be_falsey
      end
    end

    describe '#resource_ids' do
      subject { control.resource_ids(feature_key, resource_name) }

      it 'returns all the resource ids for the given feature key' do
        control.release(feature_key, resource_name, 1)
        control.release(feature_key, resource_name, 2)
        control.release(feature_key, resource_name, 15)

        expect(control.resource_ids(feature_key, resource_name)).to match_array(%w[1 2 15])
      end
    end

    describe '#released_features_to_all' do
      it 'returns all the values to given features' do
        control.release_to_all('feature1', resource_name)
        control.release_to_all('feature2', resource_name)
        control.release_to_all('feature15', resource_name)

        features_list = control.released_features_to_all(resource_name)

        expect(features_list).to match_array(%w[feature1 feature2 feature15])
      end
    end

    describe '#released_to_all?' do
      let(:result) { control.released_to_all?(feature_key, resource_name) }

      context 'when feature was not released to all' do
        before { control.unrelease_to_all(feature_key, resource_name) }

        it { expect(result).to be_falsey }
      end

      context 'when feature was released to all' do
        before { control.release_to_all(feature_key, resource_name) }

        it { expect(result).to be_truthy }
      end
    end

    describe '#search_keys' do
      before do
        control.release('namespace:1', resource_name, 1)
        control.release('namespace:2', resource_name, 2)
        control.release('namespace:1', 'exclusive', 3)
      end

      context 'without matching result' do
        it { expect(control.search_keys('invalid')).to be_empty }
      end

      context 'with matching results' do
        it { expect(control.search_keys('*av*nu*')).to match_array(['avenue:1', 'avenue:2']) }
      end
    end
  end
end
