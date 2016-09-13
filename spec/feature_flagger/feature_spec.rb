require 'spec_helper'

module FeatureFlagger
  RSpec.describe Feature do
    subject { Feature.new(key, :feature_flagger_dummy_class) }

    before do
      filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
      info = YAML.load_file(filepath)
      allow(FeatureFlagger).to receive(:config).and_return(info: info)
    end

    describe '#description' do
      context 'when feature is documented' do
        let(:key) { [:email_marketing, :behavior_score] }
        it { expect(subject.description).to eq 'Enable behavior score experiment' }
      end

      context 'when feature is not documented' do
        let(:key) { [:email_marketing, :new_email_flow] }
        it { expect { subject.description }.to raise_error(FeatureFlagger::KeyNotFoundError) }
      end
    end

    describe '#key' do
      let(:key)          { [:email_marketing, :behavior_score] }
      let(:resolved_key) { 'feature_flagger_dummy_class:email_marketing:behavior_score' }

      it 'returns the given key resolved and joined with resource_name' do
        expect(subject.key).to eq resolved_key
      end
    end
  end
end
