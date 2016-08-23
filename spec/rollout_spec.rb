require 'spec_helper'

RSpec.describe FeatureFlagger do
  describe '.configure' do
    let(:redis) { double('redis') }

    before do
      FeatureFlagger.configure do |config|
        config.redis           = redis
        config.redis_namespace = 'rollout'
      end
    end

    it { expect(FeatureFlagger.config[:redis]).to eq redis }
    it { expect(FeatureFlagger.config[:redis_namespace]).to eq 'rollout' }
  end
end
