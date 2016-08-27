module FeatureFlagger
  class Control
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
      feature_key_arr = Array(feature_key)
      feature_key_arr.insert(0, resource_name) unless resource_name.nil?
      feature_key_arr.join(':')
    end
  end
end
