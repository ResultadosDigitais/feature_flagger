namespace :feature_flagger do
  desc "cleaning up keys from storage that are no longer in the rollout.yml file"
  task :cleanup_removed_rollouts => :environment do
    keys = FeatureFlagger::Manager.detached_feature_keys
    puts "Found keys to remove: #{keys}"
    keys.each do |key|
      FeatureFlagger::Manager.cleanup_detached key
    end
  end

  desc "Release feature to given identifiers, Usage: `$ bundle exec rake feature_flagger:release\[Account,email_marketing:whitelabel,1,2,3,4\]`"
  task :release, [:entity_name, :feature_key] => :environment do |_, args|
    entity = args.entity_name.constantize
    entity_ids = args.extras
    entity.release_id(entity_ids, *args.feature_key.split(':'))
  end

  desc "Unrelease feature to given identifiers, Usage: `$ bundle exec rake feature_flagger:unrelease\[Account,email_marketing:whitelabel,1,2,3,4\]`"
  task :unrelease, [:entity_name, :feature_key] => :environment do |_, args|
    entity, entity_ids = args.entity_name.constantize, args.extras
    entity.unrelease_id(entity_ids, *args.feature_key.split(':'))
  end

  desc "Release one feature to all entity ids, Usage: `$ bundle exec rake feature_flagger:release_to_all\[Account,email_marketing:whitelabel\]`"
  task :release_to_all, [:entity_name, :feature_key] => :environment do |_, args|
    entity = args.entity_name.constantize
    entity.release_to_all(*args.feature_key.split(':'))
  end

  desc "Unrelease one feature to all entity ids, Usage: `$ bundle exec rake feature_flagger:unrelease_to_all\[Account,email_marketing:whitelabel\]`"
  task :unrelease_to_all, [:entity_name, :feature_key] => :environment do |_, args|
    entity = args.entity_name.constantize
    entity.unrelease_to_all(*args.feature_key.split(':'))
  end
end
