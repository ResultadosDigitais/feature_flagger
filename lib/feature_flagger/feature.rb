module FeatureFlagger
  class Feature
    def initialize(feature_key = nil, resource_name)
      @feature_key = resolve_key(feature_key, resource_name)
      @doc = self.class.fetch_config
      fetch_data
    end

    def description
      @data['description']
    end

    def key
      @feature_key.join(':')
    end

    def childs_keys
      @data.select { |child_key, _| child_key != 'description' }
           .collect { |child_key, _| "#{key}:#{child_key}" }
    end

    def self.all_keys(resource_name)
      keys_and_child_keys = root_features.map do |key|
        feature = Feature.new([key], resource_name)
        [feature.key] + feature.childs_keys
      end

      keys_and_child_keys.flatten
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

    def self.root_features
      doc = fetch_config
      doc[doc.keys.first].keys
    end

    def self.fetch_config
      FeatureFlagger.config.info
    end
  end
end

class FeatureFlagger::KeyNotFoundError < StandardError ; end
