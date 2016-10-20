[![Build Status](https://travis-ci.org/ResultadosDigitais/feature_flagger.svg?branch=master)](https://travis-ci.org/ResultadosDigitais/feature_flagger) [![Code Climate](https://codeclimate.com/github/ResultadosDigitais/feature_flagger/badges/gpa.svg)](https://codeclimate.com/github/ResultadosDigitais/feature_flagger) [![Issue Count](https://codeclimate.com/github/ResultadosDigitais/feature_flagger/badges/issue_count.svg)](https://codeclimate.com/github/ResultadosDigitais/feature_flagger)

# FeatureFlagger

Partially release your features.

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
You can configure this by using `configure` like such:

1. In a initializer file (e.g. `config/initializers/feature_flagger.rb`):
```ruby
require 'redis-namespace'
require 'feature_flagger'

FeatureFlagger.configure do |config|
  namespaced = ::Redis::Namespace.new("feature_flagger", redis: $redis)
  config.storage = FeatureFlagger::Storage::Redis.new(namespaced)
end
```

2. Create a `rollout.yml` in _config_ path and declare a rollout:
```yml
account: # model name
  email_marketing: # namespace (optional)
    new_email_flow: # feature key
      description:
        @dispatch team uses this rollout to introduce a new email flow for certains users. Read more at [link]
```

3. Adds rollout funcionality to your model:
```ruby
class Account < ActiveRecord::Base
  include FeatureFlagger::Model
  # ....
end
```

## Usage

```ruby
account = Account.first

# Release feature for account
account.release(:email_marketing, :new_email_flow)
#=> true

# Check feature for a given account
account.rollout?(:email_marketing, :new_email_flow)
#=> true

# Remove feature for given account
account.unrelease(:email_marketing, :new_email_flow)
#=> true

# If you try to check an inexistent rollout key it will raise an error.
account.rollout?(:email_marketing, :new_email_flow)
FeatureFlagger::KeyNotFoundError: ["account", "email_marketing", "new_email_flo"]

# Get an array with all released Account ids
Account.all_released_ids_for(:email_marketing, :new_email_flow)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ResultadosDigitais/feature_flagger.
