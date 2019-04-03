module FeatureFlagger
  class Control
    attr_reader :storage

    RELEASED_FEATURES = 'released_features'

    def initialize(storage)
      @storage = storage
    end

    def released?(feature_key, resource_id)
      @storage.has_value?(RELEASED_FEATURES, feature_key) || @storage.has_value?(feature_key, resource_id)
    end

    def release(feature_key, resource_id)
      @storage.add(feature_key, resource_id)
    end

    def release_to_all(feature_key)
      @storage.add_all(RELEASED_FEATURES, feature_key)
    end

    def unrelease(feature_key, resource_id)
      @storage.remove(feature_key, resource_id)
    end

    def unrelease_to_all(feature_key)
      @storage.remove_all(RELEASED_FEATURES, feature_key)
    end

    def resource_ids(feature_key)
      @storage.all_values(feature_key)
    end

    def released_features_to_all
      @storage.all_values(RELEASED_FEATURES)
    end

    def released_to_all?(feature_key)
      @storage.has_value?(RELEASED_FEATURES, feature_key)
    end
  end
end
