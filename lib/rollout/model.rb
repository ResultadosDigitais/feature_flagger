module Rollout
  # Model provides convinient methods for Rails Models
  # class Account
  #   include Rollout::Model
  # end
  #
  # Example:
  # Account.first.rollout?([:email_marketing, :new_awesome_feature])
  # #=> true
  module Model
    def rollout?(feature_key)
      feature_key = Array(feature_key)
      feature_key << self.class.name.parameterize('_')

      Control.rollout?(feature_key, id)
    end

    def release!(feature_key)
      feature_key = Array(feature_key)
      feature_key << self.class.name.parameterize('_')

      Control.release!(feature_key, id)
    end

    def unrelease!(feature_key)
      feature_key = Array(feature_key)
      feature_key << self.class.name.parameterize('_')

      Control.unrelease!(feature_key, id)
    end
  end
end
