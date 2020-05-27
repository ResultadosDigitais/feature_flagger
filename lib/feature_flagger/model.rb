# frozen_string_literal: true

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
      self.class.released_id?(feature_flagger_identifier, feature_key)
    end

    def release(*feature_key)
      self.class.release_id(feature_flagger_identifier, *feature_key)
    end

    def releases
      self.class.release_keys(feature_flagger_identifier)
    end

    def unrelease(*feature_key)
      resource_name = self.class.feature_flagger_model_settings.entity_name
      feature = Feature.new(feature_key, resource_name)
      FeatureFlagger.control.unrelease(feature.feature_key, resource_name, id)
    end

    private

    def feature_flagger_identifier
      public_send(self.class.feature_flagger_model_settings.identifier_field)
    end

    def feature_flagger_name
      self.class.feature_flagger_model_settings.entity_name
    end

    module ClassMethods
      def feature_flagger
        raise ArgumentError unless block_given?

        yield feature_flagger_model_settings
      end

      def released_id?(resource_id, *feature_key)
        entity_name = feature_flagger_model_settings.entity_name
        feature = Feature.new(feature_key, entity_name)
        FeatureFlagger.control.released?(feature.feature_key, entity_name, resource_id)
      end

      def release_id(resource_id, *feature_key)
        entity_name = feature_flagger_model_settings.entity_name
        feature = Feature.new(feature_key, entity_name)
        FeatureFlagger.control.release(feature.feature_key, entity_name, resource_id)
      end

      def release_keys(resource_id)
        FeatureFlagger.control.all_feature_keys(feature_flagger_model_settings.entity_name, resource_id)
      end

      def unrelease_id(resource_id, *feature_key)
        resource_name = feature_flagger_model_settings.entity_name
        feature = Feature.new(feature_key, resource_name)
        FeatureFlagger.control.unrelease(feature.feature_key, resource_name, resource_id)
      end

      def all_released_ids_for(*feature_key)
        resource_name = feature_flagger_model_settings.entity_name
        feature_key.flatten!
        feature = Feature.new(feature_key, resource_name)
        FeatureFlagger.control.resource_ids(feature.feature_key, resource_name)
      end

      def release_to_all(*feature_key)
        resource_name = feature_flagger_model_settings.entity_name

        feature = Feature.new(feature_key, resource_name)
        FeatureFlagger.control.release_to_all(feature.feature_key, resource_name)
      end

      def unrelease_to_all(*feature_key)
        resource_name = feature_flagger_model_settings.entity_name

        feature = Feature.new(feature_key, resource_name)
        FeatureFlagger.control.unrelease_to_all(feature.feature_key, resource_name)
      end

      def released_features_to_all
        FeatureFlagger.control.released_features_to_all(feature_flagger_model_settings.entity_name)
      end

      def released_to_all?(*feature_key)
        resource_name = feature_flagger_model_settings.entity_name

        feature = Feature.new(feature_key, resource_name)
        FeatureFlagger.control.released_to_all?(feature.feature_key, resource_name)
      end

      def detached_feature_keys
        Manager.detached_feature_keys(feature_flagger_model_settings.entity_name)
      end

      def cleanup_detached(*feature_key)
        Manager.cleanup_detached(feature_flagger_model_settings.entity_name, feature_key)
      end

      def rollout_resource_name
        klass_name = to_s
        klass_name.gsub!(/::/, '_')
        klass_name.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
        klass_name.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        klass_name.tr!('-', '_')
        klass_name.downcase!
        klass_name
      end

      def feature_flagger_model_settings
        @feature_flagger_model_settings ||= FeatureFlagger::ModelSettings.new(
          identifier_field: :id,
          entity_name: rollout_resource_name
        )
      end

      def feature_flagger_identifier
        public_send(feature_flagger_model_settings.identifier_field)
      end
    end
  end
end
