require 'spec_helper'

module FeatureFlagger
  RSpec.describe Configuration do
    describe '.storage' do
      let(:configuration) { described_class.new }

      context 'no storage set' do
        it 'returns a Redis storage by default' do
          expect(configuration.storage).to be_a(FeatureFlagger::Storage::Redis)
        end
      end

      context 'storage set' do
        let(:storage) { double('storage') }

        before { configuration.storage = storage }

        it 'returns storage' do
          expect(configuration.storage).to eq storage
        end
      end
    end
  end
end
