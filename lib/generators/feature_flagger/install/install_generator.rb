require 'rails/generators'
module FeatureFlagger
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def generate_rollout
        copy_file "rollout.yml", "#{Rails.root}/config/rollout.yml"
      end

      def generate_feature_flagger
        copy_file "feature_flagger.rb", "#{Rails.root}/config/initializers/feature_flagger.rb"
      end
    end
  end
end
