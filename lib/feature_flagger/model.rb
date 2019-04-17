module FeatureFlagger
  # Model provides convinient methods for Rails Models
  # class Account
  #   include FeatureFlagger::Model
  # end
  #
  # Example:
  # Account.first.rollout?([:email_marketing, :new_awesome_feature])
  # #=> true
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    def released?(*feature_key)
      self.class.released_id?(id, feature_key)
    end

    def release(*feature_key)
      self.class.release_id(id, *feature_key)
    end

    def unrelease(*feature_key)
      resource_name = self.class.rollout_resource_name
      feature = Feature.new(feature_key, resource_name)
      FeatureFlagger.control.unrelease(feature.key, id)
    end

    module ClassMethods

      def released_id?(resource_id, *feature_key)
        feature = Feature.new(feature_key, rollout_resource_name)
        FeatureFlagger.control.released?(feature.key, resource_id)
      end

      def release_id(resource_id, *feature_key)
        feature = Feature.new(feature_key, rollout_resource_name)
        FeatureFlagger.control.release(feature.key, resource_id)
      end

      def all_released_ids_for(*feature_key)
        feature_key.flatten!
        feature = Feature.new(feature_key, rollout_resource_name)
        FeatureFlagger.control.resource_ids(feature.key)
      end

      def release_to_all(*feature_key)
        feature = Feature.new(feature_key, rollout_resource_name)
        FeatureFlagger.control.release_to_all(feature.key)
      end

      def unrelease_to_all(*feature_key)
        feature = Feature.new(feature_key, rollout_resource_name)
        FeatureFlagger.control.unrelease_to_all(feature.key)
      end

      def released_features_to_all
        FeatureFlagger.control.released_features_to_all
      end

      def released_to_all?(*feature_key)
        feature = Feature.new(feature_key, rollout_resource_name)
        FeatureFlagger.control.released_to_all?(feature.key)
      end

      def detached_feature_keys
        persisted_features = FeatureFlagger.control.search_keys("#{rollout_resource_name}:*").to_a
        mapped_feature_keys = FeatureFlagger.config.mapped_feature_keys(rollout_resource_name)
        (persisted_features - mapped_feature_keys).map { |key| key.sub("#{rollout_resource_name}:",'') }
      end

      def remove_detached_feature_key(key)
        key_value = FeatureFlagger.config.info[rollout_resource_name].dig(*key.split(":"))
        raise "key is still mapped" if key_value
        FeatureFlagger.control.unrelease_to_all("#{rollout_resource_name}:#{key}")
      end

      def rollout_resource_name
        klass_name = self.to_s
        klass_name.gsub!(/::/, '_')
        klass_name.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        klass_name.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        klass_name.tr!("-", "_")
        klass_name.downcase!
        klass_name
      end
    end
  end
end
