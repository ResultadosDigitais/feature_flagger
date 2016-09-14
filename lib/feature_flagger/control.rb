module FeatureFlagger
  class Control
    attr_reader :storage

    def initialize(storage)
      @storage = storage
    end

    def rollout?(feature_key, resource_id, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      @storage.has_value?(feature_key, resource_id)
    end

    def release!(feature_key, resource_id, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      @storage.add(feature_key, resource_id)
    end

    def unrelease!(feature_key, resource_id, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      @storage.remove(feature_key, resource_id)
    end

    def resource_ids(feature_key, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      @storage.all_values(feature_key)
    end

    private

    def rsolv_key(feature_key, resource_name = nil)
      resolved_key = nil
      if resource_name
        resolved_key = feature_key
      else
        resource_name + '.' + feature_key
      end
      resolved_key.tr('.', ':')
    end
  end
end
