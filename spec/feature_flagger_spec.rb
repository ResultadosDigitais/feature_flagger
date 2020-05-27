# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FeatureFlagger do
  describe '.configure' do
    let(:storage) { double('storage') }
    let(:other_storage) { double('other_storage') }

    before do
      FeatureFlagger.configure do |config|
        config.storage = storage
      end
    end

    it { expect(FeatureFlagger.config.storage).to eq storage }

    it 'Calling configure with a new storage must change control.storage' do
      FeatureFlagger.configure do |config|
        config.storage = other_storage
      end

      expect(FeatureFlagger.config.storage).to eq other_storage
      expect(FeatureFlagger.control.storage).to eq other_storage
    end
  end

  describe '.control' do
    let(:control) { FeatureFlagger.control }

    before do
      FeatureFlagger.configure do |config|
      end
    end

    it 'initializes a Control with redis storage' do
      expect(control).to be_a(FeatureFlagger::Control)
      expect(control.storage).to be_a(FeatureFlagger::Storage::Redis)
    end
  end
end
