require 'spec_helper'

module FeatureFlagger
  RSpec.describe Feature do
    subject { Feature.new(key, :feature_flagger_dummy_class) }

    before do
      yaml_path = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
      FeatureFlagger.config.manifest_source = FeatureFlagger::ManifestSources::WithYamlFile.new(yaml_path)
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

    describe '#created_at' do
      let(:key) { [:email_marketing, :behavior_score] }
      it { expect(subject.created_at).to eq("2019-05-31") }
    end

    describe '#owner' do
      let(:key) { [:email_marketing, :behavior_score] }
      it { expect(subject.owner).to eq("Team Name") }
    end

    describe '#full_rollout_until' do
      let(:key) { [:email_marketing, :behavior_score] }
      it { expect(subject.full_rollout_until).to eq("2020-12-31") }
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
