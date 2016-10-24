module FeatureFlagger
  class Control
    attr_reader :storage

    RELEASED_FEATURES = 'released_features'

    def initialize(storage)
      @storage = storage
    end

    def rollout?(feature_key, resource_id)
      @storage.has_value?(RELEASED_FEATURES, feature_key) || @storage.has_value?(feature_key, resource_id)
    end

    def release(feature_key, resource_id)
      @storage.add(feature_key, resource_id)
    end

    def release_for_all(feature_key)
      @storage.add(RELEASED_FEATURES, feature_key)
    end

    # <b>DEPRECATED:</b> Please use <tt>release</tt> instead.
    def release!(feature_key, resource_id)
      warn "[DEPRECATION] `release!` is deprecated.  Please use `release` instead."
      release(feature_key, resource_id)
    end

    def unrelease(feature_key, resource_id)
      @storage.remove(feature_key, resource_id)
    end

    def unrelease_for_all(feature_key)
      @storage.remove(RELEASED_FEATURES, feature_key)
    end

    # <b>DEPRECATED:</b> Please use <tt>unrelease</tt> instead.
    def unrelease!(feature_key, resource_id)
      warn "[DEPRECATION] `unrelease!` is deprecated.  Please use `unrelease` instead."
      unrelease(feature_key, resource_id)
    end

    def resource_ids(feature_key)
      @storage.all_values(feature_key)
    end
  end
end
