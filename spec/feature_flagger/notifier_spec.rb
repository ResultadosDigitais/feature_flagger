require 'spec_helper'

module FeatureFlagger
  RSpec.describe Notifier do
    let(:feature_key)           { 'account:email_marketing:whitelabel' }
    let(:legacy_feature_key)   { 'account' }
    let(:resource_id)   { 'resource_id' }
    let(:resource_name) { 'account' }

    describe '#send' do
      context 'When having a callback configured' do
        let(:notifier_callback) { spy(lambda { |event| }, :is_a? => Proc)}
        let(:notifier) { Notifier.new(notifier_callback)}
        let(:generic_event) {
          {
            type: FeatureFlagger::Notifier::RELEASE,
            model: resource_name,
            feature: feature_key,
            id: resource_id
          }
        }
        context 'When call the lambda function' do
          before { notifier.send(FeatureFlagger::Notifier::RELEASE, feature_key, resource_id) }

          it { expect(notifier_callback).to have_received(:call) }
        end

        context 'When trigger the expected event' do
          let(:feature_action) { FeatureFlagger::Notifier::RELEASE }
          let(:event) { generic_event.merge({ type: feature_action})}
          before { notifier.send(feature_action, feature_key, resource_id) }

          context 'When do a release' do
            it { expect(notifier_callback).to have_received(:call).with(generic_event) }
          end

          context 'When call unrelease' do
            let(:feature_action) { FeatureFlagger::Notifier::UNRELEASE }

            it { expect(notifier_callback).to have_received(:call).with(event) }
          end

          context 'When release to all' do
            let(:feature_action) { FeatureFlagger::Notifier::RELEASE_TO_ALL }

            it { expect(notifier_callback).to have_received(:call).with(event) }
          end

          context 'When unrelease to all' do
            let(:feature_action) { FeatureFlagger::Notifier::UNRELEASE_TO_ALL }

            it { expect(notifier_callback).to have_received(:call).with(event) }
          end

          context 'When release a legacy key' do
            let(:event) { generic_event.merge({ model: "legacy key", feature: legacy_feature_key})}
            before { notifier.send(FeatureFlagger::Notifier::RELEASE, legacy_feature_key, resource_id) }

            it { expect(notifier_callback).to have_received(:call).with(event) }
          end
        end
      end

      context 'Wgeb not have a callback configured' do
        let(:notifier) { Notifier.new(nil)}
        let(:event) {
          {
            type: FeatureFlagger::Notifier::RELEASE,
            model: resource_name,
            feature: feature_key,
            id: resource_id
          }
        }

        it 'Must not raise error when no callback is configured' do
           expect { notifier.send(FeatureFlagger::Notifier::RELEASE, feature_key, resource_id) }.not_to raise_error
        end
      end
    end
  end
end
