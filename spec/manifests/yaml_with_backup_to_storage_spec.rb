require 'spec_helper'
require 'feature_flagger/manifest_sources/yaml_with_backup_to_storage'

module FeatureFlagger
  module ManifestSources
    RSpec.describe YAMLWithBackupToStorage do
      describe '.resolved_info' do        
        context 'with local yaml file to storage' do
          it 'returns a yaml file from yaml_path with backup to storage' do
            storage = spy('Storage')
            yaml_path = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
            yaml_data = YAML.load_file(yaml_path)
            yaml_as_string = YAML.dump(yaml_data)

            manifest_source = YAMLWithBackupToStorage.new(storage, yaml_path)
            expect(manifest_source.resolved_info).to eq(yaml_data)

            expect(storage).to have_received(:write_manifest_backup).with(yaml_as_string)
          end
        end
      end
    end
  end
end
