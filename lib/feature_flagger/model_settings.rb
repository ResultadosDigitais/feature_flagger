# frozen_string_literal: true

module FeatureFlagger
  class ModelSettings
    def initialize(arguments)
      arguments.each do |field, value|
        public_send("#{field}=", value)
      end
    end

    # Public: identifier_field Refers to which field must represent the unique model
    # id.
    attr_accessor :identifier_field

    # Public: entity_name to which entity the model is targeting.
    # Take this yaml file as example:
    #
    # account:
    #   email_marketing:
    #       whitelabel:
    #         description: a rollout
    #         owner: core
    # account_in_migration:
    #   email_marketing:
    #       whitelabel:
    #         description: a rollout
    #         owner: core
    #
    # class Account < ActiveRecord::Base
    #   include FeatureFlagger::Model
    #
    #   feature_flagger do |config|
    #     config.identifier_field = :cdp_tenant_id
    #     config.entity_name = :account_in_migration
    #   end
    attr_accessor :entity_name
  end
end
