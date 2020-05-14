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
      self.class.released_id?(feature_flagger_identifier, feature_flagger_key, feature_key)
    end

    def release(*feature_key)
      self.class.release_id(feature_flagger_identifier, feature_flagger_key, *feature_key)
    end

    def releases
      self.class.release_keys(feature_flagger_key)
    end

    def unrelease(*feature_key)
      resource_name = self.class.feature_flagger_model_settings.entity_name
      feature = Feature.new(feature_key, resource_name)
      FeatureFlagger.control.unrelease(feature.key, id, feature_flagger_key)
    end

    private

    def feature_flagger_identifier
      public_send(self.class.feature_flagger_model_settings.identifier_field)
    end

    def feature_flagger_name
      self.class.feature_flagger_model_settings.entity_name
    end

    def feature_flagger_key
      "#{feature_flagger_name}:#{feature_flagger_identifier}"
    end

    module ClassMethods
      def feature_flagger
        raise ArgumentError unless block_given?
        yield feature_flagger_model_settings
      end

      def released_id?(resource_id, resource_key, *feature_key)
        feature = Feature.new(feature_key, feature_flagger_model_settings.entity_name)
        FeatureFlagger.control.released?(feature.key, resource_id, resource_key)
      end

      def release_id(resource_id, resource_key, *feature_key)
        feature = Feature.new(feature_key, feature_flagger_model_settings.entity_name)
        FeatureFlagger.control.release(feature.key, resource_id, resource_key)
      end

      def release_keys(resource_key)
        FeatureFlagger.control.all_keys(resource_key)
      end

      def unrelease_id(resource_id, resource_key, *feature_key)
        feature = Feature.new(feature_key, feature_flagger_model_settings.entity_name)
        FeatureFlagger.control.unrelease(feature.key, resource_id, resource_key)
      end

      def all_released_ids_for(*feature_key)
        feature_key.flatten!
        feature = Feature.new(feature_key, feature_flagger_model_settings.entity_name)
        FeatureFlagger.control.resource_ids(feature.key)
      end

      def release_to_all(*feature_key)
        feature = Feature.new(feature_key, feature_flagger_model_settings.entity_name)
        FeatureFlagger.control.release_to_all(feature.key)
      end

      def unrelease_to_all(*feature_key)
        feature = Feature.new(feature_key, feature_flagger_model_settings.entity_name)
        FeatureFlagger.control.unrelease_to_all(feature.key)
      end

      def released_features_to_all
        FeatureFlagger.control.released_features_to_all
      end

      def released_to_all?(*feature_key)
        feature = Feature.new(feature_key, feature_flagger_model_settings.entity_name)
        FeatureFlagger.control.released_to_all?(feature.key)
      end

      def detached_feature_keys
        rollout_resource_name = feature_flagger_model_settings.entity_name
        persisted_features = FeatureFlagger.control.search_keys("#{rollout_resource_name}:*").to_a
        mapped_feature_keys = FeatureFlagger.config.mapped_feature_keys(rollout_resource_name)
        (persisted_features - mapped_feature_keys).map do |key| 
          key.sub("#{rollout_resource_name}:",'') unless (key =~ /#{rollout_resource_name}:\d+/)
        end.compact
      end

      def cleanup_detached(*feature_key)
        complete_feature_key = feature_key.map(&:to_s).insert(0, feature_flagger_model_settings.entity_name)
        key_value = FeatureFlagger.config.info.dig(*complete_feature_key)
        raise "key is still mapped" if key_value
        FeatureFlagger.control.unrelease_to_all(complete_feature_key.join(':'))
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
