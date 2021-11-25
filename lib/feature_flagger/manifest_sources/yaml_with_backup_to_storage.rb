module FeatureFlagger
  module ManifestSources
    class YAMLWithBackupToStorage

      # FeatureFlagger.configure do |config|
      #   config.manifest_source = FeatureFlagger::ManifestSources::YAMLWithBackupToStorage.new(config.storage)
      # end
      def initialize(storage, yaml_filepath = nil)
        @yaml_path = "#{Rails.root}/config/rollout.yml" if defined?(Rails)
        @storage   = storage
      end

      def resolved_info
        @resolved_info ||= begin
          yaml_data = YAML.load_file(@yaml_filepath) if @yaml_filepath
          @storage.write_manifest_backup(YAML.dump(yaml_data))
          yaml_data
        end
      end
    end
  end
end