# frozen_string_literal: true

module FeatureFlagger
  class KeyResolver
    def initialize(feature_key, resource_name)
      @feature_key = feature_key
      @resource_name = resource_name
    end

    def normalized_key
      @normalized_key ||= Array(@feature_key).flatten
                                             .map(&:to_s)
    end

    def normalized_key_with_name
      @normalized_key_with_name ||= [@resource_name] + normalized_key
    end
  end
end
