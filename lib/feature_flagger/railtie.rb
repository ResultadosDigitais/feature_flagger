# frozen_string_literal: true

if defined?(Rails)
  module FeatureFlagger
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/feature_flagger.rake'
      end
    end
  end
end
