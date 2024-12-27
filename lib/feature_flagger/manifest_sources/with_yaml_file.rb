module FeatureFlagger
  module ManifestSources
    class WithYamlFile
      def initialize(yaml_path = nil)
        @yaml_path = yaml_path
        @yaml_path ||= "#{Rails.root}/config/rollout.yml" if defined?(Rails)
      end

      def resolved_info
        @resolved_info ||= ::YAML.oad_file(@yaml_path, permitted_classes: [Date]) if @yaml_path
      end
    end
  end
end
