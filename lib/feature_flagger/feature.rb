module FeatureFlagger
  class KeyNotFoundError < StandardError; end

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

  class Feature
    def initialize(feature_key, resource_name)
      @key_resolver = KeyResolver.new(feature_key, resource_name.to_s)

      fetch_data
    end

    def description
      @data['description']
    end

    def feature_key
      @key_resolver.normalized_key.join(':')
    end

    private

    def config_info
      FeatureFlagger.config.info
    end

    def fetch_data
      @data ||= find_value(config_info, *@key_resolver.normalized_key_with_name)

      raise FeatureFlagger::KeyNotFoundError, @feature_key if @data.nil?

      @data
    end

    def find_value(hash, key, *tail)
      value = hash[key]

      if value.nil? || tail.empty?
        value
      else
        find_value(value, *tail)
      end
    end
  end
end
