require 'spec_helper'
require 'feature_flagger/manifest_sources/with_yaml_file'

module FeatureFlagger
  module ManifestSources
    RSpec.describe WithYamlFile do
      describe '.resolved_info' do        
        context 'whit local yaml file' do
          it 'returns a yaml file from yaml_path' do
            yaml_path = File.expand_path('../../fixtures/rollout_example.yml', __FILE__)
            manifest_source = WithYamlFile.new(yaml_path)
            expect(manifest_source.resolved_info).to eq(YAML.load_file(yaml_path))
          end
        end
      end
		end
  end
end
