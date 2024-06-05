module FeatureFlagger
  class Control
    attr_reader :storage

    RELEASED_FEATURES = 'released_features'

    def initialize(storage, notifier, cache_store = nil)
      @storage = storage
      @notifier = notifier
      @cache_store = cache_store
    end

    def released?(feature_key, resource_id, options = {})
      cache "released/#{feature_key}/#{resource_id}", options do
        @storage.has_value?(RELEASED_FEATURES, feature_key) || @storage.has_value?(feature_key, resource_id)
      end
    end

    def release(feature_key, resource_id)
      resource_name = Storage::Keys.extract_resource_name_from_feature_key(
        feature_key
      )

      @notifier.send(FeatureFlagger::Notifier::RELEASE, feature_key, resource_id)
      @storage.add(feature_key, resource_name, resource_id)
    end

    def releases(resource_name, resource_id, options = {})
      cache "releases/#{resource_name}/#{resource_id}", options do
        @storage.fetch_releases(resource_name, resource_id, RELEASED_FEATURES)
      end
    end

    def release_to_all(feature_key)
      @notifier.send(FeatureFlagger::Notifier::RELEASE_TO_ALL, feature_key)
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

    def resource_ids(feature_key, options = {})
      cache "all_values/#{feature_key}", options do
        @storage.all_values(feature_key)
      end
    end

    def released_features_to_all(options = {})
      cache "released_features_to_all/#{RELEASED_FEATURES}", options do
        @storage.all_values(RELEASED_FEATURES)
      end
    end

    def released_to_all?(feature_key, options = {})
      cache "has_value/#{RELEASED_FEATURES}/#{feature_key}", options do
        @storage.has_value?(RELEASED_FEATURES, feature_key)
      end
    end

    def release_count(feature_key)
      @storage.count(feature_key)
    end

    # DEPRECATED: this method will be removed from public api on v2.0 version.
    # use instead the feature_keys method.
    def search_keys(query)
      @storage.search_keys(query)
    end

    def feature_keys
      @storage.feature_keys - [FeatureFlagger::Control::RELEASED_FEATURES]
    end

    def cache(name, options, &block)
      if @cache_store
        @cache_store.fetch(name, force: options[:skip_cache]) do
          block.call
        end
      else
        block.call
      end
    end

  end
end
