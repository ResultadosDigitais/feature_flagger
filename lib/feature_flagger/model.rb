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
    def rollout?(feature_key)
      Feature.new(feature_key, rollout_resource_name).fetch!
      Control.rollout?(feature_key, id, rollout_resource_name)
    end

    def release!(feature_key)
      Feature.new(feature_key, rollout_resource_name).fetch!
      Control.release!(feature_key, id, rollout_resource_name)
    end

    def unrelease!(feature_key)
      Feature.new(feature_key, rollout_resource_name).fetch!
      Control.unrelease!(feature_key, id, rollout_resource_name)
    end

    private

    def rollout_resource_name
      klass_name = self.class.name
      klass_name.gsub!(/::/, '_')
      klass_name.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      klass_name.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      klass_name.tr!("-", "_")
      klass_name.downcase!
      klass_name
    end
  end
end
