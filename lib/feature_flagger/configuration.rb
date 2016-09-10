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

    private

    def default_yaml_filepath
      "#{Rails.root}/config/rollout.yml" if defined?(Rails)
    end
  end
end
