require 'spec_helper'

RSpec.describe FeatureFlagger::Storage::RedisKeys do
  describe '.resource_key' do
    it 'generates the resource_key' do
      prefix = "my_prefix"
      resource_name = "account"
      resource_id = "1"

      result = FeatureFlagger::Storage::RedisKeys.resource_key(
        prefix,
        resource_name,
        resource_id,
      )

      expect(result).to eq "my_prefix:account:1"
    end
  end
end