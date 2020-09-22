module FeatureFlagger
  class Control
    attr_reader :storage, :notifier

    RELEASED_FEATURES = 'released_features'

    def initialize(storage, notifier)
      @storage = storage
      @notifier = notifier
    end

    def released?(feature_key, resource_id)
      @storage.has_value?(RELEASED_FEATURES, feature_key) || @storage.has_value?(feature_key, resource_id)
    end

    def release(feature_key, resource_id)
      resource_name = Storage::Keys.extract_resource_name_from_feature_key(
        feature_key
      )

      @notifier.send(FeatureFlagger::Notifier::RELEASE, feature_key, resource_id)
      @storage.add(feature_key, resource_name, resource_id)
    end

    def releases(resource_name, resource_id)
      @storage.fetch_releases(resource_name, resource_id, RELEASED_FEATURES)
    end

    def release_to_all(feature_key)
      @notifier.send(FeatureFlagger::Notifier::UNRELEASE_TO_ALL, feature_key)
      @storage.add_all(RELEASED_FEATURES, feature_key)
    end

    def unrelease(feature_key, resource_id)
      resource_name = Storage::Keys.extract_resource_name_from_feature_key(
        feature_key
      )
      @notifier.send(FeatureFlagger::Notifier::UNRELEASE, feature_key, resource_id)
      @storage.remove(feature_key, resource_name, resource_id)
    end

    def unrelease_to_all(feature_key)
      @notifier.send(FeatureFlagger::Notifier::UNRELEASE_TO_ALL, feature_key)
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
      @storage.feature_keys - [FeatureFlagger::Control::RELEASED_FEATURES]
    end
  end
end
