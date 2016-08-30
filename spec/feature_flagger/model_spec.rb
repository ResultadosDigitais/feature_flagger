require 'spec_helper'

module FeatureFlagger

  class DummyClass
    include FeatureFlagger::Model
    def id; 14 end
  end

  RSpec.describe Model do
    subject       { DummyClass.new }
    let(:key)     { [:email_marketing, :whitelabel] }
    let(:control) { FeatureFlagger.control }

    before do
      filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
      info = YAML.load_file(filepath)
      allow(FeatureFlagger).to receive(:config).and_return(info: info)
    end

    describe '#release!' do
      it 'calls Control#release! with appropriated methods' do
        expect(control).to receive(:release!).with(key, subject.id, 'feature_flagger_dummy_class')
        subject.release!(key)
      end
    end

    describe '#rollout?' do
      it 'calls Control#rollout? with appropriated methods' do
        expect(control).to receive(:rollout?).with(key, subject.id, 'feature_flagger_dummy_class')
        subject.rollout?(key)
      end
    end

    describe '#unrelease!' do
      it 'calls Control#unrelease! with appropriated methods' do
        expect(control).to receive(:unrelease!).with(key, subject.id, 'feature_flagger_dummy_class')
        subject.unrelease!(key)
      end
    end

    describe '.all_released_ids_for' do
      it 'calls Control#resource_ids with appropriated methods' do
        expect(Control).to receive(:resource_ids).with(key, 'feature_flagger_dummy_class')
        DummyClass.all_released_ids_for(key)
      end
    end
  end
end
