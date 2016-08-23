module FeatureFlagger
  module Control
    extend self

    def rollout?(feature_key, resource_id, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      FeatureFlagger.redis.sismember(feature_key, resource_id)
    end

    def release!(feature_key, resource_id, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      FeatureFlagger.redis.sadd(feature_key, resource_id)
    end

    def unrelease!(feature_key, resource_id, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      FeatureFlagger.redis.srem(feature_key, resource_id)
    end

    def resource_ids(feature_key, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      FeatureFlagger.redis.smembers(feature_key)
    end

    private

    def rsolv_key(feature_key, resource_name = nil)
      feature_key_arr = Array(feature_key)
      feature_key_arr.insert(0, resource_name) unless resource_name.nil?
      feature_key_arr.join(':')
    end
  end
end
