module FeatureFlagger
  class Notifier
    attr_reader :notify

    RELEASE = 'release'.freeze
    UNRELEASE = 'unrelease'.freeze
    RELEASE_TO_ALL = 'release_to_all'.freeze
    UNRELEASE_TO_ALL = 'unrelease_to_all'.freeze

    def initialize(notify)
      @notify = check_notify(notify)
    end

    def send(operation, feature_key, resource_id = nil)
      @notify.call(build_event(operation, extract_resource_from_key(feature_key), feature_key, resource_id)) if notify?
    end

    private

    def check_notify(notify)
      return nil if notify.nil?
    raise ArgumentError, "Notifier callback should be a lambda" unless notify.is_a?(Proc)
      notify
    end

    def notify?
      !@notify.nil?
    end

    def extract_resource_from_key(key)
      Storage::Keys.extract_resource_name_from_feature_key(
        key
      )
      rescue FeatureFlagger::Storage::Keys::InvalidResourceNameError
      "legacy key"
    end

    def build_event(operation, resource_name, feature_key, resource_id)
      {
        type: operation,
        model: resource_name,
        feature: feature_key,
        id: resource_id
      }
    end
  end
end
