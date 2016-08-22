# Rollout

Partial release your features.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rollout'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rollout

## Usage

### Rails

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
  include Rollout::Model
  # ....
end
```


3. Check;
```ruby
class DashboardController < ApplicationController
  def index
    if current_user.account.rollout?([:email_marketing, :new_email_flow])
      # render something
    else
      # render something else
    end            
  end
end
```

P.S: If you try to check a inexistent rollout key will raise an error.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ResultadosDigitais/rollout.

