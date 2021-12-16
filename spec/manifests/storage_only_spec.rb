require 'spec_helper'
require 'feature_flagger/manifest_sources/storage_only'

module FeatureFlagger
  module ManifestSources
    RSpec.describe StorageOnly do
      describe '.resolved_info' do        
        context 'without local yaml file' do
          it 'returns a yaml file from storage' do

            storage = spy('Storage')
            yaml_path = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
            yaml_data = YAML.load_file(yaml_path)
            yaml_as_string = YAML.dump(yaml_data)
            allow(storage).to receive(:read_manifest_backup).and_return(yaml_as_string)

            manifest_source = StorageOnly.new(storage)
            expect(manifest_source.resolved_info).to eq(yaml_data)
          end
        end
      end
    end
  end
end
