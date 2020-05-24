require 'spec_helper'

module FeatureFlagger
  RSpec.describe FeatureKeysMigration do
    subject(:feature_key) { described_class.new(control) }
    let(:key)             { 'avenue:traffic_light' }
    let(:value)           { 42 }
    let(:redis)           { FakeRedis::Redis.new }
    let(:storage)         { Storage::Redis.new(redis) }
    let(:control)         { Control.new(storage) }

    describe '.call' do
      before do
        allow(control).to receive(:search_keys).and_return([key])
        allow(control).to receive(:resource_ids).and_return([value])

        feature_key.call
      end

      it 'validates feature key presence' do
        expect(control.released?('avenue:42', 'avenue:traffic_light')).to be_truthy
      end
    end
  end
end
