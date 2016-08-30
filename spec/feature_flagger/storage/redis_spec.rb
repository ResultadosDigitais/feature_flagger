require 'spec_helper'

RSpec.describe FeatureFlagger::Storage::Redis do
  let(:redis)   { Redis.new(url: ENV['REDIS_URL']) }
  let(:storage) { described_class.new }
  let(:key)   { 'foo' }
  let(:value) { 'bar' }

  describe '#redis' do
    context 'no redis client assigned' do
      let(:host) { 'redishost' }
      let(:port) { 1234 }
      let(:url)  { "redis://#{host}:#{port}" }

      around :each do |example|
        storage.redis = nil
        redis_url = ENV['REDIS_URL']
        ENV['REDIS_URL'] = url
        example.run
        ENV['REDIS_URL'] = redis_url
      end

      it 'initializes a default redis namespace on REDIS_URL env' do
        expect(storage.redis.namespace).to eq described_class::DEFAULT_NAMESPACE
        expect(storage.redis.client.host).to eq host
        expect(storage.redis.client.port).to eq port
      end
    end

    context 'with redis assigned' do
      before do
        storage.redis = redis
      end

      it 'uses the given redis' do
        expect(storage.redis).to eq redis
      end
    end
  end

  context do
    before do
      storage.redis = redis
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
