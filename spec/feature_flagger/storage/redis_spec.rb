require 'spec_helper'

RSpec.describe FeatureFlagger::Storage::Redis do
  let(:redis)   { FakeRedis::Redis.new }
  let(:storage) { described_class.new(redis) }
  let(:key)   { 'foo' }
  let(:value) { 'bar' }

  context do
    before do
      redis.flushdb
    end

    describe '#has_value?' do
      context 'value is stored for given key' do
        before { redis.sadd(key, value) }
        it { expect(storage).to have_value(key, value) }
      end

      context 'value is not stored for given key' do
        it { expect(storage).not_to have_value(key, value) }
      end
    end

    describe '#add' do
      it 'adds the value to redis' do
        storage.add(key, value)
        expect(redis.sismember(key, value)).to be_truthy
      end
    end

    describe '#remove' do
      it 'removes the value from redis' do
        redis.sadd(key, value)
        storage.remove(key, value)
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
