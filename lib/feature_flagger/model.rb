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

    def rollout?(*feature_key)
      self.class.released_id?(id, feature_key)
    end

    def released_features(*feature_key)
      self.class.released_features(id, feature_key)
    end

    # <b>DEPRECATED:</b> Please use <tt>release</tt> instead.
    def release!(*feature_key)
      warn "[DEPRECATION] `release!` is deprecated.  Please use `release` instead."
      release(*feature_key)
    end

    def release(*feature_key)
      resource_name = self.class.rollout_resource_name
      feature = Feature.new(feature_key, resource_name)
      FeatureFlagger.control.release(feature.key, id)
    end

    # <b>DEPRECATED:</b> Please use <tt>unrelease</tt> instead.
    def unrelease!(*feature_key)
      warn "[DEPRECATION] `unrelease!` is deprecated.  Please use `unrelease` instead."
      unrelease(*feature_key)
    end

    def unrelease(*feature_key)
      resource_name = self.class.rollout_resource_name
      feature = Feature.new(feature_key, resource_name)
      FeatureFlagger.control.unrelease(feature.key, id)
    end

    module ClassMethods
      def released_id?(resource_id, *feature_key)
        feature = Feature.new(feature_key, rollout_resource_name)
        FeatureFlagger.control.rollout?(feature.key, resource_id)
      end

      def released_features(resource_id, *feature_key)
        if feature_key
          features_keys = Feature.new(feature_key, rollout_resource_name).childs_keys
        else
          features_keys = Feature.all_keys(rollout_resource_name)
        end
        
        FeatureFlagger.control.released_features(features_keys, resource_id)
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
