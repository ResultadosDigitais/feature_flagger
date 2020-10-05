require 'byebug'
module FeatureFlagger
  class Notifier
    attr_reader :notify

    RELEASE = 'release'.freeze
    UNRELEASE = 'unrelease'.freeze
    RELEASE_TO_ALL = 'release_to_all'.freeze
    UNRELEASE_TO_ALL = 'unrelease_to_all'.freeze

    def initialize(notify)
      @notify = valid_notify?(notify) ? notify : nullNotify
    end

    def send(operation, feature_key, resource_id = nil)
      @notify.call(build_event(operation, extract_resource_from_key(feature_key), feature_key, resource_id))
    end

    private

    def nullNotify
      lambda {|e| }
    end

    def valid_notify?(notify)
      !notify.nil? && notify.is_a?(Proc)
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
