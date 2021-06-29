require 'spec_helper'

module FeatureFlagger
  RSpec.describe Control do
    let(:redis) { FakeRedis::Redis.new }
    let(:notify) { spy(lambda { |event|  }, :is_a? => Proc) }
    let(:notifier) { Notifier.new(notify)}
    let(:storage) { Storage::Redis.new(redis) }
    let(:cache_store) { nil }
    let(:control) { Control.new(storage, notifier, cache_store) }
    let(:key)         { 'account:email_marketing:whitelabel' }
    let(:resource_id) { 'resource_id' }
    let(:resource_name) { 'account' }

    before do
      redis.flushdb
    end

    describe '#released?' do
      let(:result) { control.released?(key, resource_id) }

      context 'when resource entity id has no access to release_key' do
        it { expect(result).to be_falsey }

        context 'and a feature is release to all' do
          before { control.release_to_all(key) }

          it { expect(result).to be_truthy }
        end
      end

      context 'when resource entity id has access to release_key' do
        before { control.release(key, resource_id) }

        it { expect(result).to be_truthy }

        context 'and a feature is release to all' do
          before { control.release_to_all(key) }

          it { expect(result).to be_truthy }
        end
      end

      context 'when cache is configured' do
        let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

        it 'only hits the storage once' do
          expect(storage).to receive(:has_value?).twice
          10.times { control.released?(key, resource_id) }
        end
      end
    end

    describe '#release' do
      it 'adds resource_id to storage' do
        control.release(key, resource_id)
        expect(control).to be_released(key, resource_id)
      end

      it 'sends to notifer the release event' do
        expect(notify).to receive(:call).with({ type: FeatureFlagger::Notifier::RELEASE,
                                                model: 'account',
                                                feature: key,
                                                id: resource_id })
        control.release(key, resource_id)
      end
    end

    describe '#releases' do
      it 'return all releases to a given resource' do
        control.release(key, resource_id)
        resource_name = 'account'

        expect(control.releases(resource_name, resource_id)).to match_array(['account:email_marketing:whitelabel'])
      end

      it 'does not return releases from another resource' do
        control.release(key, resource_id)
        control.release_to_all('user:another_rollout:global_whitelabel')
        resource_name = 'account'

        expect(control.releases(resource_name, resource_id)).to match_array(['account:email_marketing:whitelabel'])
      end

      context 'when cache is configured' do
        let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

        it 'only hits the storage once' do
          control.release(key, resource_id)

          expect(storage).to receive(:fetch_releases).once
          2.times { control.releases(resource_name, resource_id) }
        end

        it 'hits the storage n times when skip_cache is provided' do
          control.release(key, resource_id)

          expect(storage).to receive(:fetch_releases).twice
          2.times { control.releases(resource_name, resource_id, skip_cache: true) }
        end
      end
    end

    describe '#release_to_all' do
      it 'adds feature_key to storage' do
        control.release(key, resource_id)
        control.release_to_all(key)
        expect(control.releases(resource_name, 1)).to include(key)
        expect(control.released_features_to_all).to include(key)
      end

      it 'sends to notifer the release to all event' do
        expect(notify).to receive(:call).with({ type: FeatureFlagger::Notifier::RELEASE_TO_ALL,
                                                model: 'account',
                                                feature: key,
                                                id: nil })
        control.release_to_all(key)
      end
    end

    describe '#unrelease' do
      it 'removes resource_id from storage' do
        control.release(key, resource_id)
        control.unrelease(key, resource_id)
        expect(control.released?(key, resource_id)).to be_falsey
      end

      it 'sends to notifer the unrelease event' do
        expect(notify).to receive(:call).with({ type: FeatureFlagger::Notifier::UNRELEASE,
                                                model: 'account',
                                                feature: key,
                                                id: resource_id })
        control.unrelease(key, resource_id)
      end
    end

    describe '#unrelease_to_all' do
      it 'removes feature_key to storage' do
        control.release_to_all(key)
        control.unrelease_to_all(key)
        expect(control.released_features_to_all).not_to include(key)
      end

      it 'removes added resources' do
        control.release(key, 1)
        control.unrelease_to_all(key)
        expect(control.released?(key, 1)).to be_falsey
        expect(control.released_features_to_all).not_to include(key)
      end

      it 'sends to notifer the unrelease to all event' do
        expect(notify).to receive(:call).with({ type: FeatureFlagger::Notifier::UNRELEASE_TO_ALL,
                                                model: 'account',
                                                feature: key,
                                                id: nil })
        control.unrelease_to_all(key)
      end
    end

    describe '#resource_ids' do
      subject { control.resource_ids(key) }

      it 'returns all the values to given key' do
        control.release(key, 1)
        control.release(key, 2)
        control.release(key, 15)
        expect(subject).to match_array %w[1 2 15]
      end

      it 'hits the storage n times without cache' do
        expect(storage).to receive(:all_values).twice
        2.times { control.resource_ids(key) }
      end

      context 'when caching is configured' do
        let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

        it 'only hits the storage once' do
          expect(storage).to receive(:all_values).once
          2.times { control.resource_ids(key) }
        end

        it 'hits the storage n times when skip_cache is provided' do
          expect(storage).to receive(:all_values).twice

          2.times { control.resource_ids(key, skip_cache: true) }
        end
      end
    end

    describe '#released_features_to_all' do
      subject { control.released_features_to_all }

      it 'returns all the values to given features' do
        control.release_to_all('account:feature:name1')
        control.release_to_all('account:feature:name2')
        control.release_to_all('account:feature:name15')
        expect(subject).to match_array %w[account:feature:name1 account:feature:name2 account:feature:name15]
      end

      context 'when caching is configured' do
        let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

        it 'only hits the storage once' do
          expect(storage).to receive(:all_values).once
          5.times { control.released_features_to_all }
        end
      end
    end

    describe '#released_to_all?' do
      let(:result) { control.released_to_all?(key) }

      context 'when feature was not released to all' do
        it { expect(result).to be_falsey }
      end

      context 'when feature was released to all' do
        before { control.release_to_all(key) }

        it { expect(result).to be_truthy }
      end

      context 'when caching is configured' do
        let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

        it 'only hits the storage once' do
          expect(storage).to receive(:all_values).once
          5.times { control.released_features_to_all }
        end
      end
    end

    describe '#search_keys' do
      before do
        control.release("model:namespace:1", 1)
        control.release("model:namespace:2", 2)
        control.release("model:exclusive", 3)
      end

      context 'without matching result' do
        it { expect(control.search_keys('invalid').to_a).to be_empty }
      end

      context 'with matching results' do
        it { expect(control.search_keys("*ame*pac*").to_a).to contain_exactly('model:namespace:1', 'model:namespace:2') }
      end
    end

    describe '#feature_keys' do
      it 'returns only feature keys in storage' do
        another_key = "account:some_other_feature"
        control.release(key, resource_id)
        control.release_to_all(another_key)

        expect(control.feature_keys).to match_array([key])
      end
    end
  end
end
