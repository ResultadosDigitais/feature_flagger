# frozen_string_literal: true

module FeatureFlagger
  class KeyDecomposer
    def self.decompose(complete_feature_key)
      decomposed_key = complete_feature_key.split(':')
      resource_name = decomposed_key.shift

      [resource_name, decomposed_key]
    end
  end
end
