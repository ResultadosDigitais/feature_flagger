require 'spec_helper'

module Rollout
  RSpec.describe Control do
    let(:storage) { Storage::Redis.new(Rollout.redis) }
    let(:control) { Control.new(storage) }

    before do
      Rollout.redis = Redis.new(url: ENV['REDIS_URL'])
      Rollout.redis.flushdb
    end

    describe '.rollout?' do
      let(:result) { control.rollout?([:email_marketing, :new_flow], 'resource_id') }

      context 'when resource entity id has no access to release_key' do
        it { expect(result).to be_falsey }
      end

      context 'when resource entity id has access to release_key' do
        before { control.release!([:email_marketing, :new_flow], 'resource_id') }
        it { expect(result).to be_truthy }
      end
    end

    describe '.release!'
    describe '.unrelease!'
    describe '.resource_ids' do
      context 'when resource_name is nil' do
        subject { control.resource_ids([:email_marketing, :whitelabel]) }

        before do
          control.release!([:email_marketing, :whitelabel], 1)
          control.release!([:email_marketing, :whitelabel], 2)
          control.release!([:email_marketing, :whitelabel], 15)
        end

        it { is_expected.to eq %w{1 2 15} }
      end

      context 'when resource_name is passed' do
        subject { control.resource_ids([:email_marketing, :whitelabel], :account) }

        before do
          control.release!('account:email_marketing:whitelabel', 30)
          control.release!('account:email_marketing:whitelabel', 40)
          control.release!('account:email_marketing:whitelabel', 50)
        end

        it { is_expected.to eq %w{ 30 40 50 } }
      end
    end
  end
end
