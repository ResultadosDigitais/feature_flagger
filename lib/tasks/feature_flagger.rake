# frozen_string_literal: true

namespace :feature_flagger do
  desc "cleaning up keys from storage that are no longer in the rollout.yml file, Usage: `$ bundle exec rake feature_flagger:cleanup_removed_rollouts\[Account\] `"
  task :cleanup_removed_rollouts, %i[entity_name] => :environment do
    resource_name = args.entity_name.constantize
    feature_keys = FeatureFlagger::Manager.detached_feature_keys(resource_name)
    puts "Found keys to remove: #{feature_keys}"
    feature_keys.each do |feature_key|
      FeatureFlagger::Manager.cleanup_detached(resource_name, feature_key)
    rescue RuntimeError, 'key is still mapped'
      next
    end
  end

  namespace :storage do
    namespace :redis do
      desc 'Migrate the old key format to the new one, Usage: `$ bundle exec rake feature_flagger:storage:redis:migrate`'
      task :migrate do |_, _args|
        require 'feature_flagger'

        redis = ::Redis::Namespace.new(
          FeatureFlagger::Storage::Redis::DEFAULT_NAMESPACE,
          redis: ::Redis.new(url: ENV['REDIS_URL'])
        )
        control = FeatureFlagger.control

        FeatureFlagger::Storage::FeatureKeysMigration.new(redis, control).call
      end
    end
  end

  desc "Release feature to given identifiers, Usage: `$ bundle exec rake feature_flagger:release\[Account,email_marketing:whitelabel,1,2,3,4\]`"
  task :release, %i[entity_name feature_key] => :environment do |_, args|
    entity = args.entity_name.constantize
    entity_ids = args.extras
    entity.release_id(entity_ids, *args.feature_key.split(':'))
  end

  desc "Unrelease feature to given identifiers, Usage: `$ bundle exec rake feature_flagger:unrelease\[Account,email_marketing:whitelabel,1,2,3,4\]`"
  task :unrelease, %i[entity_name feature_key] => :environment do |_, args|
    entity = args.entity_name.constantize
    entity_ids = args.extras
    entity.unrelease_id(entity_ids, *args.feature_key.split(':'))
  end

  desc "Release one feature to all entity ids, Usage: `$ bundle exec rake feature_flagger:release_to_all\[Account,email_marketing:whitelabel\]`"
  task :release_to_all, %i[entity_name feature_key] => :environment do |_, args|
    entity = args.entity_name.constantize
    entity.release_to_all(*args.feature_key.split(':'))
  end

  desc "Unrelease one feature to all entity ids, Usage: `$ bundle exec rake feature_flagger:unrelease_to_all\[Account,email_marketing:whitelabel\]`"
  task :unrelease_to_all, %i[entity_name feature_key] => :environment do |_, args|
    entity = args.entity_name.constantize
    entity.unrelease_to_all(*args.feature_key.split(':'))
  end
end
