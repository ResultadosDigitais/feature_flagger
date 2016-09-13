module FeatureFlagger
  class Feature

    def initialize(feature_key, resource_name = nil)
      @feature_key = resource_name.nil? ? feature_key : feature_key.clone.insert(0, resource_name)
      @feature_key = Array(@feature_key).collect(&:to_s)
      @doc = FeatureFlagger.config[:info]
    end

    def fetch!
      @data ||= find_value(@doc, *@feature_key)
      raise FeatureFlagger::KeyNotFoundError.new(@feature_key) if @data.nil?
      @data
    end

    def description
      fetch!
      @data['description']
    end

    def key
      @feature_key.join(':')
    end

    private

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
