module FeatureFlagger
  class Configuration
    attr_accessor :storage, :cache_store, :manifest_source, :notifier_callback

    def initialize
      @storage         ||= Storage::Redis.default_client
      @manifest_source ||= FeatureFlagger::ManifestSources::YAML.new
      @notifier_callback = nil
      @cache_store = nil
    end

    def cache_store=(cache_store)
      raise ArgumentError, "Cache is only support when used with ActiveSupport" unless defined?(ActiveSupport)

      cache_store = :null_store if cache_store.nil?
      @cache_store = ActiveSupport::Cache.lookup_store(*cache_store)
    end

    def info
      @manifest_source.resolved_info
    end

    def mapped_feature_keys(resource_name = nil)
      info_filtered = resource_name ? info[resource_name] : info
      [].tap do |keys|
        make_keys_recursively(info_filtered).each { |key| keys.push(join_key(resource_name, key)) }
      end
    end

    private

    def make_keys_recursively(hash, keys = [], composed_key = [])
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

    def join_key(resource_name, key)
      key.unshift resource_name if resource_name
      key.join(":")
    end
  end
end
