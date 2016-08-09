require 'spec_helper'

module Rollout
  RSpec.describe Control do
    include Control

    before do
      Rollout.redis = Redis.new(url: ENV['REDIS_URL'])
      Rollout.redis.flushdb
    end

    describe '.rollout?' do
      let(:result) { rollout?([:email_marketing, :new_flow], 'resource_id') }

      context 'when resource entity id has no access to release_key' do
        it { expect(result).to be_falsey }
      end

      context 'when resource entity id has access to release_key' do
        before do
          release!([:email_marketing, :new_flow], 'resource_id')
        end

        it { expect(result).to be_truthy }
      end
    end

    describe '.release!'
    describe '.unrelease!'
    describe '.resource_ids'
  end
end
