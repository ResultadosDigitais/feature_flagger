module FeatureFlagger
  module Storage
    module RedisKeys
      MINIMUM_VALID_FEATURE_PATH = 2.freeze

      def self.resource_key(prefix, resource_name, resource_id)
        "#{prefix}:#{resource_name}:#{resource_id}"
      end

      def self.extract_resource_name_from_feature_key(feature_key)
        feature_paths = feature_key.split(':')
  
        raise InvalidResourceNameError if feature_paths.size < MINIMUM_VALID_FEATURE_PATH
  
        feature_paths.first
      end
  
      class InvalidResourceNameError < StandardError; end
    end
  end
end