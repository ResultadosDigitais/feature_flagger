module FeatureFlagger
  class FeatureKeysMigration

    def initialize(from_redis, to_control)
      @from_redis = from_redis
      @to_control = to_control
    end

    def call
      @from_redis.keys("*").map{ |key| migrate_key(key) }.flatten
    end

    private

    def migrate_key(key)
      resource_ids = @from_redis.smembers(key)

      keys_array = key.split(':')
      resource_name = keys_array.shift

      return false if key =~ /#{resource_name}:\d+/

      @to_control.release(keys_array.join(':'), resource_name, resource_ids)
    end
  end
end
