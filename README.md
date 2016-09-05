[![Code Climate](https://codeclimate.com/github/ResultadosDigitais/feature_flagger/badges/gpa.svg)](https://codeclimate.com/github/ResultadosDigitais/feature_flagger) [![Issue Count](https://codeclimate.com/github/ResultadosDigitais/feature_flagger/badges/issue_count.svg)](https://codeclimate.com/github/ResultadosDigitais/feature_flagger)

# FeatureFlagger

Partial release your features.

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

1. Configure redis by adding `config/initializers/feature_flagger.rb`:
```ruby
FeatureFlagger.configure do |config|
  config.storage.redis = $redis
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
account.release!([:email_marketing, :new_email_flow])
#=> true

# Check feature for a given account
account.rollout?([:email_marketing, :new_email_flow])
#=> true

# Remove feature for given account
account.unrelease!([:email_marketing, :new_email_flow])
#=> true

# If you try to check an inexistent rollout key it will raise an error.
account.rollout?([:email_marketing, :new_email_flo])
FeatureFlagger::KeyNotFoundError: ["account", "email_marketing", "new_email_flo"]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ResultadosDigitais/feature_flagger.
