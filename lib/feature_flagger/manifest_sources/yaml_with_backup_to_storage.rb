module FeatureFlagger
  module ManifestSources
    class YAMLWithBackupToStorage
      def initialize(storage, yaml_path = nil)
        @yaml_path = yaml_path || ("#{Rails.root}/config/rollout.yml" if defined?(Rails))
        @storage   = storage
      end

      def resolved_info
        @resolved_info ||= begin
          yaml_data = YAML.load_file(@yaml_path) if @yaml_path
          @storage.write_manifest_backup(YAML.dump(yaml_data))
          yaml_data
        end
      end
    end
  end
end
