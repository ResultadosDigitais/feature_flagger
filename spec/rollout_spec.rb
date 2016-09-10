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

  describe '.storage' do
    context 'no storage set' do
      it 'returns a Redis storage by default' do
        FeatureFlagger.config.storage = nil
        expect(FeatureFlagger.config.storage).to be_a(FeatureFlagger::Storage::Redis)
      end
    end

    context 'storage set' do
      let(:storage) { double('storage') }

      it 'returns storage' do
        FeatureFlagger.configure do |config|
          config.storage = storage
        end
        expect(FeatureFlagger.config.storage).to eq storage
      end
    end
  end
end
