require 'spec_helper'

module FeatureFlagger
  RSpec.describe Notifier do
    let(:feature_key)           { 'account:email_marketing:whitelabel' }
    let(:legacy_feature_key)   { 'account' }
    let(:resource_id)   { 'resource_id' }
    let(:resource_name) { 'account' }

    describe 'Having a callback configured' do
      let(:notifier_callback) { spy(lambda { |event| }, :is_a? => Proc)}
      let(:notifier) { Notifier.new(notifier_callback)}
      describe '#send' do
        let(:generic_event) {
          {
            type: FeatureFlagger::Notifier::RELEASE,
            model: resource_name,
            feature: feature_key,
            id: resource_id
          }
        }
        context 'Should call the lambda function' do
          before { notifier.send(FeatureFlagger::Notifier::RELEASE, feature_key, resource_id) }

          it { expect(notifier_callback).to have_received(:call) }
        end

        context 'Should trigger the correct event on' do
          context 'Release' do
            before { notifier.send(FeatureFlagger::Notifier::RELEASE, feature_key, resource_id) }

            it { expect(notifier_callback).to have_received(:call).with(generic_event) }
          end

          context 'Unrelease' do
            before { notifier.send(FeatureFlagger::Notifier::UNRELEASE, feature_key, resource_id) }
            let(:event) { generic_event.merge({ type: FeatureFlagger::Notifier::UNRELEASE})}

            it { expect(notifier_callback).to have_received(:call).with(event) }
          end

          context 'Release to all' do
            before { notifier.send(FeatureFlagger::Notifier::RELEASE_TO_ALL, feature_key) }
            let(:event) { generic_event.merge({ type: FeatureFlagger::Notifier::RELEASE_TO_ALL, id: nil})}

            it { expect(notifier_callback).to have_received(:call).with(event) }
          end

          context 'Unrelease to all' do
            before { notifier.send(FeatureFlagger::Notifier::UNRELEASE_TO_ALL, feature_key) }
            let(:event) { generic_event.merge({ type: FeatureFlagger::Notifier::UNRELEASE_TO_ALL, id: nil})}

            it { expect(notifier_callback).to have_received(:call).with(event) }
          end

          context 'legacy key' do
            before { notifier.send(FeatureFlagger::Notifier::RELEASE, legacy_feature_key, resource_id) }
            let(:event) { generic_event.merge({ model: "legacy key", feature: legacy_feature_key})}

            it { expect(notifier_callback).to have_received(:call).with(event) }
          end
        end
      end
    end

    describe 'Not having a callback configured' do
      let(:notifier) { Notifier.new(nil)}
      describe '#send' do
        let(:event) {
          {
            type: FeatureFlagger::Notifier::RELEASE,
            model: resource_name,
            feature: feature_key,
            id: resource_id
          }
        }
        context 'Should not raise error when no callback is configured' do
          it { expect { notifier.send(FeatureFlagger::Notifier::RELEASE, feature_key, resource_id) }.not_to raise_error }
        end
      end
    end
  end
end
