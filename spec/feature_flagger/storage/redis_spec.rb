require 'spec_helper'

RSpec.describe FeatureFlagger::Storage::Redis do
  let(:redis)   { FakeRedis::Redis.new }
  let(:storage) { described_class.new(redis) }
  let(:feature_key)   { 'account:email_marketing:whitelabel' }
  let(:resource_id)   { '1' }
  let(:resource_name) { 'account' }
  let(:global_key)    { 'released_features' }
  let(:resource_key) do
    FeatureFlagger::Storage::Keys.resource_key(
      FeatureFlagger::Storage::Redis::RESOURCE_PREFIX,
      resource_name,
      resource_id,
    )
  end

  context do
    before do
      redis.flushdb
    end

    describe '#has_values?' do
      context 'when resource_id is stored for given feature_key' do
        before { storage.add(feature_key, resource_name, resource_id) }
        it { expect(storage).to have_value(feature_key, resource_id) }
      end

      context 'when resource_id is not stored for given feature_key' do
        it { expect(storage).not_to have_value(feature_key, resource_id) }
      end
    end

    describe '#fetch_releases' do
      context 'when there is no features under global structure' do
        before do
          storage.add(feature_key, resource_name, resource_id)
        end

        it 'returns related feature_keys' do
          expect(storage.fetch_releases(resource_name, resource_id, global_key)).to match_array([feature_key])
        end
      end

      context 'when there is features under global structure' do
        before do
          storage.add_all(global_key, feature_key)
        end

        it 'returns related feature_keys' do
          expect(storage.fetch_releases(resource_name, resource_id, global_key)).to match_array(feature_key)
        end
      end
    end

    describe '#add' do
      it 'adds the resource_id to redis' do
        storage.add(feature_key, resource_name, resource_id)

        expect(storage).to have_value(feature_key, resource_id)
        expect(storage).to have_value(resource_key, feature_key)
      end
    end

    describe '#add_all' do
      context 'when only add_all is called' do
        it 'turns feature a global' do
          storage.add_all(global_key, feature_key)

          expect(storage).to have_value(global_key, feature_key)
        end
      end

      context 'when add_all is called right after add' do
        it 'turns feature a global, cleaning both local resource and feature sets' do
          storage.add(feature_key, resource_name, resource_id)
          storage.add_all(global_key, feature_key)

          expect(storage).not_to have_value(feature_key, resource_id)
          expect(storage).not_to have_value(resource_key, feature_key)
        end
      end
    end

    describe '#remove' do
      it 'removes the resource_id from redis' do
        storage.add(feature_key, resource_name, resource_id)

        storage.remove(feature_key, resource_name, resource_id)

        expect(storage).not_to have_value(feature_key, resource_id)
        expect(storage).not_to have_value(resource_key, feature_key)
      end
    end

    describe '#remove_all' do
      it 'removes all resource_ids from redis' do
        storage.add(feature_key, resource_name, resource_id)

        storage.remove_all(global_key, feature_key)

        expect(storage).not_to have_value(feature_key, resource_id)
        expect(storage).not_to have_value(resource_key, feature_key)
      end
    end

    describe '#all_resource_ids' do
      let(:resource_ids) { %w(value1 value2) }

      it 'returns all resource_ids for the given feature_key' do
        storage.add(feature_key, resource_name, resource_ids)
        expect(storage.all_values(feature_key).sort).to match_array(resource_ids)
      end
    end

    describe '#count' do
      let(:resource_ids) { %w(value1 value2) }

      it 'returns the number of resource_ids for the given feature_key' do
        storage.add(feature_key, resource_name, resource_ids)
        expect(storage.count(feature_key)).to eq(2)
      end
    end

    describe '#feature_keys' do
      it 'returns only feature_keys' do
        storage.add(feature_key, resource_name, resource_id)
        storage.add('user:profile:round_avatar', 'user', resource_id)
        storage.add('account:lp:new_layout', 'account', resource_id)
        storage.add('account:lp:new_layout', 'account', resource_id)

        expect(storage.feature_keys).to match_array([
          'account:email_marketing:whitelabel',
          'user:profile:round_avatar',
          'account:lp:new_layout',
        ])
      end
    end
  end
end
