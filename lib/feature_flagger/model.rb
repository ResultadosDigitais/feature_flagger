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
      feature_key.flatten!
      resource_name = self.class.rollout_resource_name
      feature = Feature.new(feature_key, resource_name)
      FeatureFlagger.control.rollout?(feature.key, id)
    end

    def release!(*feature_key)
      feature_key.flatten!
      resource_name = self.class.rollout_resource_name
      feature = Feature.new(feature_key, resource_name)
      FeatureFlagger.control.release!(feature.key, id)
    end

    def unrelease!(*feature_key)
      feature_key.flatten!
      resource_name = self.class.rollout_resource_name
      feature = Feature.new(feature_key, resource_name)
      FeatureFlagger.control.unrelease!(feature.key, id)
    end

    module ClassMethods
      def all_released_ids_for(*feature_key)
        feature_key.flatten!
        feature = Feature.new(feature_key, rollout_resource_name)
        Control.resource_ids(feature.key)
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
