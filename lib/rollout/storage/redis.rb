module Rollout
  module Storage
    class Redis
      def initialize(redis)
        @redis = redis
      end

      def has_value?(key, value)
        @redis.sismember(key, value)
      end

      def add(key, value)
        @redis.sadd(key, value)
      end

      def remove(key, value)
        @redis.srem(key, value)
      end

      def all_values(key)
        @redis.smembers(key)
      end
    end
  end
end
