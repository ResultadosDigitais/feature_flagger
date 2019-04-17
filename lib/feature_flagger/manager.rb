module FeatureFlagger
  class Manager

    def self.detached_feature_keys
      persisted_features = FeatureFlagger.control.search_keys("*").to_a
      mapped_feature_keys = FeatureFlagger.config.mapped_feature_keys
      persisted_features - mapped_feature_keys
    end

    def self.remove_detached_feature_key(key)
      raise "key is still mapped" if FeatureFlagger.config.info.dig(*key.split(":"))
      FeatureFlagger.control.unrelease_to_all(key)
    end

  end
end
