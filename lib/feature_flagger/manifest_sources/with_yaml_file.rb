module FeatureFlagger
  module ManifestSources
    class WithYamlFile
      def initialize(yaml_path = nil)
        @yaml_path = yaml_path
        @yaml_path ||= "#{Rails.root}/config/rollout.yml" if defined?(Rails)
      end

      def resolved_info
        @resolved_info ||= ::YAML.unsafe_load_file(@yaml_path) if @yaml_path
      end
    end
  end
end
