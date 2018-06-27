module FeatureFlagger
  class Configuration
    attr_accessor :storage, :yaml_filepath

    def initialize
      @storage       ||= Storage::Redis.default_client
      @yaml_filepath ||= default_yaml_filepath
    end

    def info
      @info ||= YAML.load_file(yaml_filepath) if yaml_filepath
    end

    def flattened_info(clue = ':')
      flattened = {}
      flatten_perform = lambda do |hash, flattened_key|
        hash.each do |key, value|
          dimension_key = flattened_key ? "#{flattened_key}#{clue}#{key}" : key
          next flatten_perform.call(value, dimension_key) unless value.is_a?(String)
          flattened[flattened_key] ||= {}
          flattened[flattened_key][key] = value
        end
      end
      flatten_perform.call(info, nil)
      flattened
    end

    private

    def default_yaml_filepath
      "#{Rails.root}/config/rollout.yml" if defined?(Rails)
    end
  end
end
