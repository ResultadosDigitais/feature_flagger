module FeatureFlagger
  class Feature
    def initialize(feature_key = nil, resource_name = nil)
      @resource_name = resource_name
      @doc = FeatureFlagger.config.info
      return if feature_key == nil

      @feature_key = resolve_key(feature_key, resource_name)
      fetch_data
    end

    def description
      @data['description']
    end

    def key
      @feature_key.join(':')
    end

    def childs_keys
      return all_keys if @feature_key == nil

      @data.select { |child_key, _| child_key != 'description' }
           .collect { |child_key, _| "#{key}:#{child_key}" }
    end

    private

    def all_keys
      keys_and_child_keys = root_features.map do |key|
        feature = Feature.new([key], @resource_name)
        [feature.key] + feature.childs_keys
      end

      keys_and_child_keys.flatten
    end

    def root_features
      @doc[@doc.keys.first].keys
    end

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
