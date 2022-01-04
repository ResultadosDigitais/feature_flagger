[![Build Status](https://travis-ci.org/ResultadosDigitais/feature_flagger.svg?branch=master)](https://travis-ci.org/ResultadosDigitais/feature_flagger) [![Code Climate](https://codeclimate.com/github/ResultadosDigitais/feature_flagger/badges/gpa.svg)](https://codeclimate.com/github/ResultadosDigitais/feature_flagger) [![Issue Count](https://codeclimate.com/github/ResultadosDigitais/feature_flagger/badges/issue_count.svg)](https://codeclimate.com/github/ResultadosDigitais/feature_flagger)

# FeatureFlagger

Partially release your features.

## Working with Docker

Open IRB
`docker-compose run feature_flagger`

Running tests
`docker-compose run feature_flagger rspec`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'feature_flagger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install feature_flagger

## Configuration

By default, feature_flagger uses the REDIS_URL env var to setup it's storage.
You can set up FeatureFlagger by creating a file called ```config/initializers/feature_flagger``` with the following lines:
```ruby
require 'redis-namespace'
require 'feature_flagger'

FeatureFlagger.configure do |config|
  redis = Redis.new(host: ENV['REDIS_URL'])
  namespaced = Redis::Namespace.new('feature_flagger', redis: redis)
  config.storage = FeatureFlagger::Storage::Redis.new(namespaced)
end
```

It's also possible to configure an additional cache layer by using ActiveSupport::Cache APIs. You can configure it the same way you would setup cache_store for Rails Apps. Caching is not enabled by default.


```ruby
configuration.cache_store = :memory_store, { expires_in: 100 }

```


1. Create a `rollout.yml` in _config_ path and declare a rollout:
```yml
account: # model name
  email_marketing: # namespace (optional)
    new_email_flow: # feature key
      description:
        @dispatch team uses this rollout to introduce a new email flow for certains users. Read more at [link]
```

2. Adds rollout funcionality to your model:
```ruby
class Account < ActiveRecord::Base
  include FeatureFlagger::Model
  # ....
end
```
#### Notifier
The notifier_callback property in config, enables the dispatch of events when a release operation happens.
```ruby
config.notifier_callback = -> {|event| do something with event }
```


It accepts a lambda function that will receive a hash with the operation triggered like:
```ruby
{
  type: 'release',
  model: 'account',
  key: 'somefeature:somerolloutkey'
  id: 'account_id' #In realease_to_all and unrelease_to_all operations id will be nil 
}
```

The supported operations are:
* release
* unrelease
* release_to_all
* unrelease_to_all 


## Usage

```ruby
account = Account.first

# Release feature for account
account.release(:email_marketing, :new_email_flow)
#=> true

# Check feature for a given account
account.released?(:email_marketing, :new_email_flow)
#=> true

# In order to bypass the cache if cache_store is configured
account.released?(:email_marketing, :new_email_flow, skip_cache: true)
#=> true

# Remove feature for given account
account.unrelease(:email_marketing, :new_email_flow)
#=> true

# If you try to check an inexistent rollout key it will raise an error.
account.released?(:email_marketing, :new_email_flow)
FeatureFlagger::KeyNotFoundError: ["account", "email_marketing", "new_email_flo"]

# Check feature for a specific account id
Account.released_id?(42, :email_marketing, :new_email_flow)
#=> true

# In order to bypass the cache if cache_store is configured
Account.released_id?(42, :email_marketing, :new_email_flow, skip_cache: true)
#=> true

# Release a feature for a specific account id
Account.release_id(42, :email_marketing, :new_email_flow)
#=> true

# Get an array with all released Account ids
Account.all_released_ids_for(:email_marketing, :new_email_flow)

# Releasing a feature to all accounts
Account.release_to_all(:email_marketing, :new_email_flow)

# Unreleasing a feature to all accounts
Account.unrelease_to_all(:email_marketing, :new_email_flow)

# Return an array with all features released for all
Account.released_features_to_all

# In order to bypass the cache if cache_store is configured
Account.released_features_to_all(skip_cache: true)

```

## Clean up action

By default when a key is removed from `rollout.yml` file, its data still in the storage.

To clean it up, execute or schedule the rake:

    $ bundle exec rake feature_flagger:cleanup_removed_rollouts

## Upgrading

When upgrading from `1.1.x` to `1.2.x` the following command must be executed
to ensure the data stored in Redis storage is right. Check [#67](https://github.com/ResultadosDigitais/feature_flagger/pull/67) and [#68](https://github.com/ResultadosDigitais/feature_flagger/pull/68) for more info.

    $ bundle exec rake feature_flagger:migrate_to_resource_keys

## Extra options

There are a few options to store/retrieve your rollout manifest (a.k.a rollout.yml):

If you have a rollout.yml file and want to use Redis to keep a backup, add the follow code to the configuration block:

```ruby
FeatureFlagger.configure do |config|
  ...
  config.manifest_source = FeatureFlagger::ManifestSources::YAMLWithBackupToStorage.new(config.storage)
  ...
end
```

If you already have your manifest on Redis and prefer not to keep a copy in your application, add the following code to the configuration block:

```ruby
FeatureFlagger.configure do |config|
  ...
  config.manifest_source = FeatureFlagger::ManifestSources::StorageOnly.new(config.storage)
  ...
end
```

If you have the YAML file and don't need a backup, it is unnecessary to do any different configuration.

## Contributing

Bug reports and pull requests are welcome!
Please take a look at our guidelines [here](CONTRIBUTING.md).
