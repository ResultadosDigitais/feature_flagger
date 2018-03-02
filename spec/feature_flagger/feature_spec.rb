require 'spec_helper'

module FeatureFlagger
  RSpec.describe Feature do
    let(:resource_name) { :feature_flagger_dummy_class }
    subject { Feature.new(key, resource_name) }

    before do
      filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
      FeatureFlagger.config.yaml_filepath = filepath
    end

    describe '#initialize' do
      context 'when feature is documented' do
        let(:key) { [:email_marketing, :behavior_score] }
        it { expect(subject).to be_a Feature }
      end

      context 'when feature is not documented' do
        let(:key) { [:email_marketing, :new_email_flow] }
        it { expect { subject }.to raise_error(FeatureFlagger::KeyNotFoundError) }
      end

      context 'with key argument as an array of arrays' do
        let(:key)          { [[:email_marketing, :behavior_score]] }
        let(:resolved_key) { 'feature_flagger_dummy_class:email_marketing:behavior_score' }
        it 'flattens the array and acts as an unidimensional array' do
          expect(subject.key).to eq resolved_key
        end
      end
    end

    describe '#description' do
      let(:key) { [:email_marketing, :behavior_score] }
      it { expect(subject.description).to eq 'Enable behavior score experiment' }
    end

    describe '#key' do
      let(:key)          { [:email_marketing, :behavior_score] }
      let(:resolved_key) { 'feature_flagger_dummy_class:email_marketing:behavior_score' }

      it 'returns the given key resolved and joined with resource_name' do
        expect(subject.key).to eq resolved_key
      end
    end

    describe '#childs_keys' do
      context 'given feature has childs' do
        let(:key) { [:email_marketing] }

        it 'returns childs keys from feature' do
          childs_keys = %w(feature_flagger_dummy_class:email_marketing:behavior_score
                          feature_flagger_dummy_class:email_marketing:whitelabel)

          expect(subject.childs_keys).to eq childs_keys
        end
      end

      context 'given feature has not childs' do
        let(:key) { [:email_marketing, :whitelabel] }

        it 'returns empty' do
          expect(subject.childs_keys).to eq []
        end
      end
    end

    describe '#all_keys' do
      it 'returns all features keys from config' do
        all_keys = %w(feature_flagger_dummy_class:email_marketing
                         feature_flagger_dummy_class:email_marketing:behavior_score
                         feature_flagger_dummy_class:email_marketing:whitelabel)

        expect(Feature.all_keys(resource_name)).to eq all_keys
      end
    end
  end
end
