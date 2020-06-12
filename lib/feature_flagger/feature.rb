# frozen_string_literal: true

module FeatureFlagger
  class KeyNotFoundError < StandardError; end

  class Feature
    def initialize(feature_key, resource_name)
      @key_resolver = KeyResolver.new(feature_key, resource_name.to_s)

      fetch_data
    end

    def description
      @data['description']
    end

    def key
      @key_resolver.normalized_key.join(':')
    end

    private

    def config_info
      FeatureFlagger.config.info
    end

    def fetch_data
      @data ||= find_value(config_info, *@key_resolver.normalized_key_with_name)

      if @data.nil? || @data["description"].nil?
        raise FeatureFlagger::KeyNotFoundError, @feature_key
      end

      @data
    end

    def find_value(hash, key, *tail)
      value = hash[key]

      if tail.any?
        return find_value(value, *tail)
      end

      value
    end
  end
end
