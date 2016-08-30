module FeatureFlagger
  module Storage
    class Redis
      DEFAULT_NAMESPACE = :feature_flagger

      attr_writer :redis

      def redis
        @redis ||= begin
          client = ::Redis.new(url: ENV['REDIS_URL'])
          ::Redis::Namespace.new(DEFAULT_NAMESPACE, redis: client)
        end
      end

      def has_value?(key, value)
        redis.sismember(key, value)
      end

      def add(key, value)
        redis.sadd(key, value)
      end

      def remove(key, value)
        redis.srem(key, value)
      end

      def all_values(key)
        redis.smembers(key)
      end
    end
  end
end
