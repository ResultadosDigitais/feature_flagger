require 'spec_helper'

module FeatureFlagger
  RSpec.describe Control do
    include Control

    before do
      FeatureFlagger.redis = Redis.new(url: ENV['REDIS_URL'])
      FeatureFlagger.redis.flushdb
    end

    describe '.rollout?' do
      let(:result) { rollout?([:email_marketing, :new_flow], 'resource_id') }

      context 'when resource entity id has no access to release_key' do
        it { expect(result).to be_falsey }
      end

      context 'when resource entity id has access to release_key' do
        before { release!([:email_marketing, :new_flow], 'resource_id') }
        it { expect(result).to be_truthy }
      end
    end

    describe '.release!'
    describe '.unrelease!'
    describe '.resource_ids' do
      context 'when resource_name is nil' do
        subject { resource_ids([:email_marketing, :whitelabel]) }

        before do
          release!([:email_marketing, :whitelabel], 1)
          release!([:email_marketing, :whitelabel], 2)
          release!([:email_marketing, :whitelabel], 15)
        end

        it { is_expected.to eq %w{1 2 15} }
      end

      context 'when resource_name is passed' do
        subject { resource_ids([:email_marketing, :whitelabel], :account) }

        before do
          release!('account:email_marketing:whitelabel', 30)
          release!('account:email_marketing:whitelabel', 40)
          release!('account:email_marketing:whitelabel', 50)
        end

        it { is_expected.to eq %w{ 30 40 50 } }
      end
    end
  end
end
