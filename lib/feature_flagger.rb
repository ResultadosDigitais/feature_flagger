require 'yaml'

require 'feature_flagger/version'
require 'feature_flagger/storage/redis'
require 'feature_flagger/control'
require 'feature_flagger/model'
require 'feature_flagger/feature'

module FeatureFlagger
  class << self
    def configure(&block)
      set_config
      yield self if block_given?
    end

    # TODO: rename to just _config_.
    def config
      @@config
    end

    def control
      @@control ||= Control.new(storage)
    end

    def storage=(storage)
      set_config
      @@config[:storage] = storage
    end

    def storage
      set_config
      @@config[:storage]
    end

    private

    def set_config
      @@config ||= {}
      @@config[:storage] ||= default_client

      # TODO: Provide a Rake to generate initial YAML file
      # for new projects.

      if defined?(Rails)
        @@config[:yaml_filepath] ||= "#{Rails.root}/config/rollout.yml"
      end

      if file_path = @@config[:yaml_filepath]
        @@config[:info] ||= YAML.load_file(file_path)
      end
    end

    def default_client
      Storage::Redis.default_client
    end
  end
end
