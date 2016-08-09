require 'spec_helper'

RSpec.describe Rollout do
  describe '.configure' do
    let(:redis) { double('redis') }

    before do
      Rollout.configure do |config|
        config.redis           = redis
        config.redis_namespace = 'rollout'
      end
    end

    it { expect(Rollout.configuration[:redis]).to eq redis }
    it { expect(Rollout.configuration[:resource_method]).to eq :current_account }
    it { expect(Rollout.configuration[:redis_namespace]).to eq 'rollout' }
  end
end
