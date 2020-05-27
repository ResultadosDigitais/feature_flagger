# frozen_string_literal: true

module FeatureFlagger
  class Manager
    def self.detached_feature_keys(resource_name)
      keys = FeatureFlagger.control.search_keys("#{resource_name}:*")

      persisted_features = keys.flat_map do |key|
        FeatureFlagger.control.all_feature_keys(resource_name, key.sub("#{resource_name}:", ''))
      end.sort.uniq

      mapped_feature_keys = FeatureFlagger.config.mapped_feature_keys(resource_name).map do |feature|
        feature.sub("#{resource_name}:", '')
      end

      persisted_features - mapped_feature_keys
    end

    def self.cleanup_detached(resource_name, *feature_key)
      feature = Feature.new(feature_key, resource_name)
      raise 'key is still mapped'
    rescue FeatureFlagger::KeyNotFoundError => _e
      # This means the keys is not present in config file anymore
      key_resolver = KeyResolver.new(feature_key, resource_name)
      FeatureFlagger.control.unrelease_to_all(key_resolver.normalized_key, resource_name)
    end
  end
end
