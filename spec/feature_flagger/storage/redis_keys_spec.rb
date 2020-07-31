require 'spec_helper'

RSpec.describe FeatureFlagger::Storage::Keys do
  describe '.resource_key' do
    it 'generates the resource_key' do
      prefix = "my_prefix"
      resource_name = "account"
      resource_id = "1"

      result = FeatureFlagger::Storage::Keys.resource_key(
        prefix,
        resource_name,
        resource_id,
      )

      expect(result).to eq "my_prefix:account:1"
    end
  end

  describe '.extract_resource_name_from_feature_key' do
    context 'when feature_key is valid' do
      it 'returns resource_name' do
        feature_key = 'account:email_marketing:whitelabel'
        result = FeatureFlagger::Storage::Keys.extract_resource_name_from_feature_key(
          feature_key
        )

        expect(result).to eq 'account'
      end
    end

    context 'when feature_key is not valid' do
      it 'returns resource_name' do
        feature_key = 'account'

        expect {
          FeatureFlagger::Storage::Keys.extract_resource_name_from_feature_key(
            feature_key
          )
        }.to raise_error(FeatureFlagger::Storage::Keys::InvalidResourceNameError)
      end
    end
  end
end
