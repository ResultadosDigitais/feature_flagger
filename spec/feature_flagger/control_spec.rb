require 'spec_helper'

module FeatureFlagger
  RSpec.describe Control do
    let(:redis) { FakeRedis::Redis.new }
    let(:control) { Control.new(Storage::Redis.new(redis)) }
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
    end

    describe '#release' do
      it 'adds resource_id to storage' do
        control.release(key, resource_id)
        expect(control).to be_released(key, resource_id)
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
    end

    describe '#release_to_all' do
      it 'adds feature_key to storage' do
        control.release(key, resource_id)
        control.release_to_all(key)
        expect(control.releases(resource_name, 1)).to include(key)
        expect(control.released_features_to_all).to include(key)
      end
    end

    describe '#unrelease' do
      it 'removes resource_id from storage' do
        control.release(key, resource_id)
        control.unrelease(key, resource_id)
        expect(control.released?(key, resource_id)).to be_falsey
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
    end

    describe '#resource_ids' do
      subject { control.resource_ids(key) }

      it 'returns all the values to given key' do
        control.release(key, 1)
        control.release(key, 2)
        control.release(key, 15)
        expect(subject).to match_array %w[1 2 15]
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
