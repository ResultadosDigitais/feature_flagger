module FeatureFlagger
  class Manager

    def self.mapped_feature_keys
      [].tap do |keys|
        make_keys_recursively(FeatureFlagger.config.info).each { |key| keys.push(key.join(":")) }
      end
    end

    def self.detached_feature_keys
      persisted_features = FeatureFlagger.control.search_keys("*").to_a
      persisted_features - mapped_feature_keys
    end

    def self.remove_feature_key(key)
      FeatureFlagger.control.unrelease_to_all(key)
    end

    private

    def self.make_keys_recursively(hash, keys = [], composed_key = [])
      unless hash.values[0].is_a?(Hash)
        keys.push(composed_key)
        return
      end

      hash.each do |key, value|
        composed_key_cloned = composed_key.clone
        composed_key_cloned.push(key.to_sym)
        make_keys_recursively(value, keys, composed_key_cloned)
      end
      keys
    end
  end
end
