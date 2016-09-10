require 'spec_helper'

module FeatureFlagger
  RSpec.describe Feature do

    before do
      filepath = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
      FeatureFlagger.config.yaml_filepath = filepath
    end

    describe '#description' do
      context 'when feature documented' do
        subject { Feature.new([:email_marketing, :behavior_score], :feature_flagger_dummy_class) }
        it { expect(subject.description).to eq 'Enable behavior score experiment' }
      end

      context 'when feature is not documented' do
        subject { Feature.new([:email_marketing, :new_email_flow], :feature_flagger_dummy_class) }
        it { expect { subject.description }.to raise_error(FeatureFlagger::KeyNotFoundError) }
      end
    end
  end
end
