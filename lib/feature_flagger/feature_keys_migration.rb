module FeatureFlagger
  class FeatureKeysMigration

    def initialize(control)
      @control = control
    end

    def call
      feature_keys = control.search_keys("*").to_a
      feature_keys.map{ |key| release_key(key) }.flatten
    end

    private

    attr_reader :control

    def release_key(feature_key)
      resource_name = feature_key.gsub(/\:.*/, '')
      return false if feature_key =~ /#{resource_name}:\d+/

      control.resource_ids(feature_key).map do |resource_id|
        control.release(feature_key, resource_id, resource_name)
      end
    end
  end
end
