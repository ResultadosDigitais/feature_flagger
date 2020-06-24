module FeatureFlagger
  class Feature
    def initialize(feature_key, resource_name = nil)
      @feature_key = resolve_key(feature_key, resource_name)
      @doc = FeatureFlagger.config.info
      fetch_data
    end

    def description
      @data['description']
    end

    def key
      @feature_key.join(':')
    end

    private

    def resolve_key(feature_key, resource_name)
      key = Array(feature_key).flatten
      key.insert(0, resource_name) if resource_name
      key.map(&:to_s)
    end

    def fetch_data
      @data ||= find_value(@doc, *@feature_key)
      raise FeatureFlagger::KeyNotFoundError.new(@feature_key) if @data.nil?
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

class FeatureFlagger::KeyNotFoundError < StandardError ; end