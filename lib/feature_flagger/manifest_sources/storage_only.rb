module FeatureFlagger
    module ManifestSources
      class StorageOnly
  
        # require 'feature_flagger/manifest_sources/storage_only'
        # 
        # FeatureFlagger.configure do |config|
        #   config.manifest_source = FeatureFlagger::ManifestSources::StorageOnly.new(config.storage)
        # end
        def initialize(storage)
          @storage   = storage
        end
  
        def resolved_info
          YAML.load(@storage.read_manifest_backup)
        end
      end
    end
  end