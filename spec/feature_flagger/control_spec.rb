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

    describe '#rollout?' do
      let(:result) { control.rollout?(key, resource_id) }

      context 'when resource entity id has no access to release_key' do
        it { expect(result).to be_falsey }
      end

      context 'when resource entity id has access to release_key' do
        before { storage.add(key, resource_id) }
        it { expect(result).to be_truthy }
      end
    end

    describe '#release' do
      it 'adds resource_id to storage' do
        control.release(key, resource_id)
        expect(storage).to have_value(key, resource_id)
      end
    end

    describe '#unrelease' do
      it 'removes resource_id from storage' do
        storage.add(key, resource_id)
        control.unrelease(key, resource_id)
        expect(storage).not_to have_value(key, resource_id)
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
  end
end
