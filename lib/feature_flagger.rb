require 'yaml'

require 'feature_flagger/version'
require 'feature_flagger/storage/redis'
require 'feature_flagger/storage/feature_keys_migration'
require 'feature_flagger/control'
require 'feature_flagger/model'
require 'feature_flagger/model_settings'
require 'feature_flagger/feature'
require 'feature_flagger/configuration'
require 'feature_flagger/manager'
require 'feature_flagger/railtie'
require 'feature_flagger/notifier'

module FeatureFlagger
  class << self
    def configure
      @@configuration = nil
      @@control = nil
      @@notifier = nil
      yield config if block_given?
    end

    def config
      @@configuration ||= Configuration.new
    end

    def notifier
      @@notifier ||= Notifier.new(config.notifier_callback)
    end

    def control
      @@control ||= Control.new(config.storage, notifier)
    end
  end
end
