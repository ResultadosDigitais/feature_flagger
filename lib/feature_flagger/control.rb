module FeatureFlagger
  class Control
    attr_reader :storage

    RELEASED_FEATURES = 'released_features'
    MINIMUM_VALID_FEATURE_PATH = 2.freeze

    def initialize(storage)
      @storage = storage
    end

    def released?(feature_key, resource_id)
      @storage.has_value?(RELEASED_FEATURES, feature_key) || @storage.has_value?(feature_key, resource_id)
    end

    def release(feature_key, resource_id)
      resource_name = extract_resource_name_from_feature_key(feature_key)
      @storage.add(feature_key, resource_name, resource_id)
    end

    def releases(resource_name, resource_id)
      @storage.fetch_releases(resource_name, resource_id, RELEASED_FEATURES)
    end

    def release_to_all(feature_key)
      @storage.add_all(RELEASED_FEATURES, feature_key)
    end

    def unrelease(feature_key, resource_id)
      resource_name = extract_resource_name_from_feature_key(feature_key)
      @storage.remove(feature_key, resource_name, resource_id)
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

    # DEPRECATED: this method will be removed from public api on v2.0 version.
    # use instead the feature_keys method.
    def search_keys(query)
      @storage.search_keys(query)
    end

    def feature_keys
      @storage.feature_keys
    end

    private

    def extract_resource_name_from_feature_key(feature_key)
      feature_paths = feature_key.split(':')

      raise InvalidResourceNameError if feature_paths.size < MINIMUM_VALID_FEATURE_PATH

      feature_paths.first
    end

    class InvalidResourceNameError < StandardError; end
  end
end
