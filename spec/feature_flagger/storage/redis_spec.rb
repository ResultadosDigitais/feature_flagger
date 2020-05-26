require 'spec_helper'

RSpec.describe FeatureFlagger::Storage::Redis do
  let(:redis)         { FakeRedis::Redis.new }
  let(:storage)       { FeatureFlagger::Storage::Redis.new(redis) }
  let(:resource_name) { 'avenue' }
  let(:resource_id)   { 'bar' }
  let(:feature_key)   { 'foo' }

  let(:global_feature_key)    { 'released_features' }

  before do
    redis.flushdb
  end

  describe '#has_value?' do
    context 'when there is a value stored for the given key' do
      it 'returns true' do
        storage.add(feature_key, resource_name, resource_id)
        expect(storage).to have_value(feature_key, resource_name, resource_id)
      end
    end

    context 'when there is not a value stored for the given key' do
      it 'returns false' do
        expect(storage).not_to have_value(feature_key, resource_name, resource_id)
      end
    end
  end

  describe '#add' do
    context 'when resource_id is an array' do
      it 'adds all the resource ids in the right place' do
        another_resource_id = 'something_else'
        storage.add(feature_key, resource_name, [resource_id, another_resource_id])

        expect(storage).to have_value(feature_key, resource_name, resource_id)
        expect(storage).to have_value(feature_key, resource_name, another_resource_id)
      end
    end

    it 'adds the resource id to the data structure' do
      storage.add(feature_key, resource_name, resource_id)

      expect(storage).to have_value(feature_key, resource_name, resource_id)
    end
  end

  describe '#add_all' do
    it 'adds feature to redis global feature key' do
      storage.add_all(global_feature_key, feature_key, resource_name)

      expect(storage.all_feature_keys(global_feature_key, resource_name, resource_id)).to include(feature_key)
    end

    it 'removes feature keys from resources' do
      storage.add(feature_key, resource_name, resource_id)

      storage.add_all(global_feature_key, feature_key, resource_name)

      expect(storage.has_value?(feature_key, resource_name, resource_id)).to be_falsey
    end
  end

  describe '#remove' do
    context 'when resource_id is an array' do
      it 'adds all the resource ids in the right place' do
        another_resource_id = 'something_else'
        storage.add(feature_key, resource_name, [resource_id, another_resource_id])

        storage.remove(feature_key, resource_name, [resource_id, another_resource_id])

        expect(storage).to_not have_value(feature_key, resource_name, resource_id)
        expect(storage).to_not have_value(feature_key, resource_name, another_resource_id)
      end
    end

    it 'removes the value from data structure' do
      storage.add(feature_key, resource_name, resource_id)

      storage.remove(feature_key, resource_name, resource_id)

      expect(storage).to_not have_value(feature_key, resource_name, resource_id)
    end
  end

  describe '#all_feature_keys' do
    it 'list all features keys for a resource' do
      another_feature_key = 'cool_feature_key'

      storage.add(another_feature_key, resource_name, resource_id)
      storage.add_all(global_feature_key, feature_key, resource_name)

      features = storage.all_feature_keys(global_feature_key, resource_name, resource_id)

      expect(features).to match_array([feature_key, another_feature_key])
    end
  end

  describe '#remove_all' do
    it 'removes feature from all resources' do
      storage.add(feature_key, resource_name, resource_id)

      storage.remove_all(global_feature_key, feature_key, resource_name)

      expect(storage).to_not have_value(feature_key, resource_name, resource_id)
    end

    it 'removes value from global feature key' do
      storage.add(feature_key, resource_name, resource_id)

      storage.remove_all(global_feature_key, feature_key, resource_name)

      expect(redis.smembers(global_feature_key)).to_not include(feature_key)
    end
  end

  describe '#all_values' do
    let(:values) { %w(value1 value2) }

    it 'returns all ids for the given feature key' do
      storage.add(feature_key, resource_name, values)

      expect(storage.all_values(feature_key, resource_name)).to match_array(values)
    end
  end
end
