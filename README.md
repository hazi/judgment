# Judgment

[![Build Status](https://travis-ci.org/hazi/judgment.svg?branch=master)](https://travis-ci.org/hazi/judgment)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'judgment', github: 'hazi/judgment'
```

And then execute:

    $ bundle


## Usage

```ruby
class SampleModel
  include Judgment

  def initialize
    @status = 1
    @price = nil
  end

  judge_for :publishable do
    judge -> { @status == 1 }, 'status is not `1`'
    judge_not -> { @price.nil? }, 'price is nil'
  end

  def publish!
    fail unless publishable?
    publish
  end
end

sample_model = SampleModel.new
sample_model.publishable? #=> false
sample_model.judgment_message(:publishable) #=> ['price is nil']
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
