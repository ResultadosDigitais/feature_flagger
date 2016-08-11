module Rollout
  module Control
    extend self

    def rollout?(feature_key, resource_id, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      Rollout.redis.sismember(feature_key, resource_id)
    end

    def release!(feature_key, resource_id, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      Rollout.redis.sadd(feature_key, resource_id)
    end

    def unrelease!(feature_key, resource_id, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      Rollout.redis.srem(feature_key, resource_id)
    end

    def resource_ids(feature_key, resource_name = nil)
      feature_key = rsolv_key(feature_key, resource_name)
      Rollout.redis.smembers(feature_key)
    end

    private

    def rsolv_key(feature_key, resource_name = nil)
      feature_key_arr = Array(feature_key)
      feature_key_arr.insert(0, resource_name) unless resource_name.nil?
      feature_key_arr.join(':')
    end
  end
end
