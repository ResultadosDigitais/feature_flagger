module FeatureFlagger
  class Feature

    def initialize(key, resource_name = nil)
      @key = resource_name.nil? ? key : key.clone.insert(0, resource_name)
      @key = Array(@key).collect(&:to_s)
      @doc = FeatureFlagger.config[:info]
    end

    def fetch!
      @data ||= find_value(@doc, *@key)
      raise FeatureFlagger::KeyNotFoundError.new(@key) if @data.nil?
      @data
    end

    def description
      fetch!
      @data['description']
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
