if defined?(Rails)
  module FeatureFlagger
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/cleanup.rake'
      end
    end
  end
end