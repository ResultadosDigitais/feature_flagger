require 'spec_helper'

RSpec.describe FeatureFlagger do
  describe '.configure' do
    let(:redis)   { double('redis') }
    let(:storage) { double('storage') }

    before do
      FeatureFlagger.configure do |config|
        config.storage = storage
      end
    end

    it { expect(FeatureFlagger.config.storage).to eq storage }
  end

  describe '.control' do
    let(:control) { FeatureFlagger.control }
    it 'initializes a Control with redis storage' do
      expect(control).to be_a(FeatureFlagger::Control)
      expect(control.storage).to be_a(FeatureFlagger::Storage::Redis)
    end
  end
end
