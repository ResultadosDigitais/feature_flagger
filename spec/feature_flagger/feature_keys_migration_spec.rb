require 'spec_helper'

module FeatureFlagger
  RSpec.describe FeatureKeysMigration do
    subject(:feature_key) { described_class }
    let(:redis)           { FakeRedis::Redis.new }
    let(:storage)         { Storage::Redis.new(redis) }
    let(:control)         { Control.new(storage) }

    describe '.call' do
      before do
        control.release('avenue:traffic_light', 42, 'avenue')
        described_class.call
      end

      it 'validates feature key presence' do
        expect(control.released?('avenue:42', 'avenue:traffic_light')).to be_truthy
      end
    end
  end
end
