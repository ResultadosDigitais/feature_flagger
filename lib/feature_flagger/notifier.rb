module FeatureFlagger
  class Notifier
    attr_reader :notify

    RELEASE = 'release'.freeze
    UNRELEASE = 'unrelease'.freeze
    RELEASE_TO_ALL = 'release_to_all'.freeze
    UNRELEASE_TO_ALL = 'unrelease_to_all'.freeze

    def initialize(notify)
      @notify = notify
    end

    def notify?
      @notify != nil
    end

    def send(operation, feature_key, resource_id = nil)
      begin
      resource_name = Storage::Keys.extract_resource_name_from_feature_key(
        feature_key
      )
      rescue FeatureFlagger::Storage::Keys::InvalidResourceNameError
        resource_name = "legacy key"
      end

      notify.call(build_event(operation, resource_name, feature_key, resource_id)) if notify?
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
