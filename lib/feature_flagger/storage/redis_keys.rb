module FeatureFlagger
  module Storage
    module RedisKeys
      def self.resource_key(prefix, resource_name, resource_id)
        "#{prefix}:#{resource_name}:#{resource_id}"
      end
    end
  end
end