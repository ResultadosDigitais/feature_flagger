module FeatureFlagger
  class Control
    attr_reader :storage

    RELEASED_FEATURES = 'released_features'

    def initialize(storage)
      @storage = storage
    end

    def released?(feature_key, resource_id)
      @storage.has_value?(RELEASED_FEATURES, feature_key) ||
        @storage.has_value?(feature_key, resource_id)
    end

    def release(feature_key, resource_id, resource_key)
      @storage.add(feature_key, resource_id, resource_key)
    end

    def release_to_all(feature_key)
      @storage.add_all(RELEASED_FEATURES, feature_key)
    end

    def all_keys(resource_key)
      @storage.all_keys(RELEASED_FEATURES, resource_key)
    end

    def unrelease(feature_key, resource_id, resource_key)
      @storage.remove(feature_key, resource_id, resource_key)
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

    def search_keys(query)
      @storage.search_keys(query)
    end

    def attach_resource_keys
      feature_keys = @storage.search_keys("*")
      feature_keys.map{ |key| release_resource_key(key) }.flatten
    end

    private

    def release_resource_key(key)
      entity = key.gsub(/\:.*/, '')
      return unless key =~ /#{entity}:\d+/

      @storage.all_values(key).map do |value|
        @storage.add_single("#{entity}:#{value}", key)
      end
    end
  end
end
