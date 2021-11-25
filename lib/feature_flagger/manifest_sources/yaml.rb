module FeatureFlagger
  module ManifestSources
    class YAML
      # require 'feature_flagger/manifest_sources/yaml'
      # FeatureFlagger.configure do |config|
      #   config.manifest_source = FeatureFlagger::ManifestSources::YAML.new
      # end
      def initialize(yaml_path = nil)
        yaml_path = "#{Rails.root}/config/rollout.yml" if defined?(Rails)
      end

      def resolved_info
        @resolved_info ||= YAML.load_file(yaml_filepath) if yaml_filepath
      end
    end
  end
end