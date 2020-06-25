module FeatureFlagger
  class Manager

    def self.detached_feature_keys
      persisted_features = FeatureFlagger.control.search_keys("*").to_a
      mapped_feature_keys = FeatureFlagger.config.mapped_feature_keys
      persisted_features - mapped_feature_keys
    end

    def self.cleanup_detached(resource_name, *feature_key)
      complete_feature_key = feature_key.map(&:to_s).insert(0, resource_name.to_s)
      key_value = FeatureFlagger.config.info.dig(*complete_feature_key)
      raise "key is still mapped" if key_value
      FeatureFlagger.control.unrelease_to_all(complete_feature_key.join(':'))
    end

  end
end
