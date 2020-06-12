# frozen_string_literal: true

require 'spec_helper'

module FeatureFlagger
  RSpec.describe Feature do
    subject { Feature.new(key, class_name) }

    let(:class_name) { :feature_flagger_dummy_class }

    before do
      filepath = File.expand_path('../fixtures/rollout_example.yml', __dir__)
      FeatureFlagger.config.yaml_filepath = filepath
    end

    describe '#initialize' do
      context 'when feature is documented' do
        let(:key) { %i[email_marketing behavior_score] }
        it { expect(subject).to be_a Feature }

        context 'when feature key is incomplete' do
          let(:key) { [:email_marketing] }
          it { expect { subject }.to raise_error(FeatureFlagger::KeyNotFoundError) }
        end
      end

      context 'when feature is not documented' do
        let(:key) { %i[email_marketing new_email_flow] }
        it { expect { subject }.to raise_error(FeatureFlagger::KeyNotFoundError) }
      end
    end

    describe '#description' do
      let(:key) { %i[email_marketing behavior_score] }
      it { expect(subject.description).to eq 'Enable behavior score experiment' }
    end

    describe '#key' do
      let(:key)          { [%i[email_marketing behavior_score]] }
      let(:resolved_key) { 'email_marketing:behavior_score' }

      it 'returns the given key resolved_key' do
        expect(subject.key).to eq resolved_key
      end
    end
  end
end
