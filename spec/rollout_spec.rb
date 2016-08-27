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

  describe '.control' do
    let(:control) { FeatureFlagger.control }
    it 'initializes a Control with redis storage' do
      expect(control).to be_a(FeatureFlagger::Control)
      expect(control.storage).to be_a(FeatureFlagger::Storage::Redis)
    end
  end
end
