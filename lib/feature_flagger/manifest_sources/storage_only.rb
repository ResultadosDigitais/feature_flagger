module FeatureFlagger
  module ManifestSources
    class StorageOnly
      def initialize(storage)
        @storage = storage
      end

      def resolved_info
        YAML.load(@storage.read_manifest_backup)
      end
    end
  end
end
