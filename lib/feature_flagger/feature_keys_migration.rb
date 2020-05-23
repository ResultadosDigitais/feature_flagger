module FeatureFlagger
  class FeatureKeysMigration

    class << self
      def call
        feature_keys = FeatureFlagger.control.search_keys("*").to_a
        feature_keys.map{ |key| release_key(key) }.flatten
      end
    
      private

      def release_key(feature_key)
        resource_name = key.gsub(/\:.*/, '')
        return false if key =~ /#{resource_name}:\d+/

        FeatureFlagger.control.all_values(feature_key).map do |resource_id|
          FeatureFlagger.control.release(feature_key, resource_id, resource_name)
        end
      end
    end
  end
end
