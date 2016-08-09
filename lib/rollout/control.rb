module Rollout
  module Control
    extend self

    def rollout?(feature_key, resource_id)
      feature_key = rsolv_key(feature_key)
      Rollout.redis.sismember(feature_key, resource_id)
    end

    def release!(feature_key, resource_id)
      feature_key = rsolv_key(feature_key)
      Rollout.redis.sadd(feature_key, resource_id)
    end

    def unrelease!(feature_key, resource_id)
      feature_key = rsolv_key(feature_key)
      Rollout.redis.srem(feature_key, resource_id)
    end

    def resource_ids(feature_key, resource_name = nil)
      feature_key << resource_name unless resource_name.nil?
      feature_key = rsolv_key(feature_key)
      Rollout.redis.smembers(resource)
    end

    private

    def rsolv_key(feature_key)
      Array(feature_key).join(':')
    end
  end
end
