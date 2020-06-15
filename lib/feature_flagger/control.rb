# frozen_string_literal: true

module FeatureFlagger
  class Control
    attr_reader :storage

    RELEASED_FEATURES = 'released_features'

    def initialize(storage)
      @storage = storage
    end

    def released?(feature_key, resource_name, resource_id)
      @storage.has_value?(feature_key, resource_name, RELEASED_FEATURES) ||
        @storage.has_value?(feature_key, resource_name, resource_id)
    end

    def release(feature_key, resource_name, resource_id)
      @storage.add(feature_key, resource_name, resource_id)
    end

    def release_to_all(feature_key, resource_name)
      @storage.add_all(RELEASED_FEATURES, feature_key, resource_name)
    end

    def all_feature_keys(resource_name, resource_id)
      @storage.all_feature_keys(RELEASED_FEATURES, resource_name, resource_id)
    end

    def unrelease(feature_key, resource_name, resource_id)
      @storage.remove(feature_key, resource_name, resource_id)
    end

    def unrelease_to_all(feature_key, resource_name)
      @storage.remove_all(feature_key, resource_name)
    end

    def resource_ids(feature_key, resource_name)
      @storage.all_values(feature_key, resource_name)
    end

    def released_features_to_all(resource_name)
      @storage.all_feature_keys(RELEASED_FEATURES, resource_name)
    end

    def released_to_all?(feature_key, resource_name)
      @storage.has_value?(feature_key, resource_name, RELEASED_FEATURES)
    end

    def search_keys(query)
      @storage.search_keys(query)
    end
  end
end
