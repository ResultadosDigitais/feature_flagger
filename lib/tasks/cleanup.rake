namespace :feature_flagger do
  desc 'cleaning up removed rollouts rake task'
  task :cleanup_removed_rollouts do
    keys = FeatureFlagger::Manager.detached_feature_keys
    keys.each do |key|
      FeatureFlagger::Manager.cleanup_detached key
    end
  end
end