require 'spec_helper'

module FeatureFlagger
  RSpec.describe Notifier do
    let(:feature_key)           { 'account:email_marketing:whitelabel' }
    let(:legacy_feature_key)   { 'account' }
    let(:resource_id)   { 'resource_id' }
    let(:resource_name) { 'account' }
    let(:feature_action) { FeatureFlagger::Notifier::RELEASE }

    describe '#send' do
      context 'With a callback configured' do
        let(:notifier_callback) { spy(lambda { |event| }, :is_a? => Proc)}
        let(:notifier) { Notifier.new(notifier_callback)}
        let(:generic_event) {
          {
            type: feature_action,
            model: resource_name,
            feature: feature_key,
            id: resource_id
          }
        }

        context 'When trigger the expected event' do
          let(:event) { generic_event.merge({ type: feature_action})}
          before { notifier.send(feature_action, feature_key, resource_id) }

          it { expect(notifier_callback).to have_received(:call).with(generic_event) }

          context 'When release a legacy key' do
            let(:event) { generic_event.merge({ model: "legacy key", feature: legacy_feature_key})}
            before { notifier.send(feature_action, legacy_feature_key, resource_id) }

            it { expect(notifier_callback).to have_received(:call).with(event) }
          end
        end
      end

      context 'When not have a callback configured' do
        let(:notifier) { Notifier.new(nil)}
        let(:event) {
          {
            type: feature_action,
            model: resource_name,
            feature: feature_key,
            id: resource_id
          }
        }

        it 'Must not raise error' do
           expect { notifier.send(feature_action, feature_key, resource_id) }.not_to raise_error
        end
      end
    end
  end
end
