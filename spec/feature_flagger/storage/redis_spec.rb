require 'spec_helper'

RSpec.describe FeatureFlagger::Storage::Redis do
  let(:redis)   { FakeRedis::Redis.new }
  let(:storage) { described_class.new(redis) }
  let(:resource_key) { 'avenue:42' }
  let(:key)   { 'foo' }
  let(:value) { 'bar' }
  let(:global_key) { 'released_features' }

  context do
    before do
      redis.flushdb
    end

    describe '#has_value?' do
      context 'value is stored for given key' do
        before { 
          redis.sadd(key, value)
          redis.sadd(resource_key, key)
        }
        it { expect(storage).to have_value(key, value) }
      end

      context 'value is not stored for given key' do
        it { expect(storage).not_to have_value(key, value) }
      end
    end

    describe '#add' do
      it 'adds the value to redis' do
        storage.add(key, value, resource_key)
        expect(redis.sismember(key, value)).to be_truthy
        expect(redis.sismember(resource_key, key)).to be_truthy
      end
    end

    describe '#add_all' do
      it 'adds value to redis global key and clear key' do
        storage.add_all(global_key, key)
        expect(redis.sismember(global_key, key)).to be_truthy
        expect(redis.sismember(key, value)).to be_falsey
      end
    end

    describe '#remove' do
      it 'removes the value from redis' do
        redis.sadd(key, value)
        redis.sadd(resource_key, key)
        storage.remove(key, value, resource_key)
        expect(redis.sismember(key, value)).to be_falsey
        expect(redis.sismember(resource_key, key)).to be_falsey
      end
    end

    describe '#all_keys' do
      it 'list all key features from redis' do
        storage.add(resource_key, key, value)
        storage.add_all(global_key, key)
        expect(storage.all_keys(global_key, resource_key)).to match([key])
      end
    end

    describe '#remove_all' do
      it 'removes all values from redis' do
        redis.sadd(key, value)
        storage.remove_all(global_key, key)
        expect(redis.sismember(key, value)).to be_falsey
      end
    end

    describe '#all_values' do
      let(:values) { %w(value1 value2) }

      it 'returns all values for the given key' do
        redis.sadd(key, values)
        expect(storage.all_values(key).sort).to eq values.sort
      end
    end
  end
end
