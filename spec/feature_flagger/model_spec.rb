require 'spec_helper'

module FeatureFlagger

  class DummyClass
    include FeatureFlagger::Model
    def id; 14 end
  end

  RSpec.describe Model do
    subject             { DummyClass.new }
    let(:key)           { [:email_marketing, :whitelabel] }
    let(:resolved_key)  { 'feature_flagger_dummy_class:email_marketing:whitelabel' }
    let(:control)       { FeatureFlagger.control }

    before do
      filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
      info = YAML.load_file(filepath)
      allow(FeatureFlagger).to receive(:config).and_return(info: info)
    end

    describe '#release!' do
      context 'with key as multiple arguments' do
        it 'calls Control#release! with appropriated methods' do
          expect(control).to receive(:release!).with(resolved_key, subject.id)
          subject.release!(*key)
        end
      end

      context 'with key argument as an array' do
        it 'calls Control#release! with appropriated methods' do
          expect(control).to receive(:release!).with(resolved_key, subject.id)
          subject.release!(key)
        end
      end
    end

    describe '#rollout?' do
      context 'with key as multiple arguments' do
        it 'calls Control#rollout? with appropriated methods' do
          expect(control).to receive(:rollout?).with(resolved_key, subject.id)
          subject.rollout?(*key)
        end
      end

      context 'with key argument as an array' do
        it 'calls Control#rollout? with appropriated methods' do
          expect(control).to receive(:rollout?).with(resolved_key, subject.id)
          subject.rollout?(key)
        end
      end
    end

    describe '#unrelease!' do
      context 'with key as multiple arguments' do
        it 'calls Control#unrelease! with appropriated methods' do
          expect(control).to receive(:unrelease!).with(resolved_key, subject.id)
          subject.unrelease!(*key)
        end
      end

      context 'with key argument as an array' do
        it 'calls Control#unrelease! with appropriated methods' do
          expect(control).to receive(:unrelease!).with(resolved_key, subject.id)
          subject.unrelease!(key)
        end
      end
    end

    describe '.all_released_ids_for' do
      context 'with key as multiple arguments' do
        it 'calls Control#resource_ids with appropriated methods' do
          expect(Control).to receive(:resource_ids).with(resolved_key)
          DummyClass.all_released_ids_for(*key)
        end
      end

      context 'with key argument as an array' do
        it 'calls Control#resource_ids with appropriated methods' do
          expect(Control).to receive(:resource_ids).with(resolved_key)
          DummyClass.all_released_ids_for(key)
        end
      end
    end
  end
end
