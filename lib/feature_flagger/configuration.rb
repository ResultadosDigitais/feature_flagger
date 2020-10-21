module FeatureFlagger
  class Configuration
    attr_accessor :storage, :yaml_filepath, :notifier_callback

    def initialize
      @storage       ||= Storage::Redis.default_client
      @yaml_filepath ||= default_yaml_filepath
      @notifier_callback = nil
    end

    def info
      @info ||= YAML.load_file(yaml_filepath) if yaml_filepath
    end

    def mapped_feature_keys(resource_name = nil)
      info_filtered = resource_name ? info[resource_name] : info
      [].tap do |keys|
        make_keys_recursively(info_filtered).each { |key| keys.push(join_key(resource_name, key)) }
      end
    end

    private

    def default_yaml_filepath
      "#{Rails.root}/config/rollout.yml" if defined?(Rails)
    end

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
