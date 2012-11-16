# Statly

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'statly'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install statly

## Usage

There are (will be) an array of different similarity classes you can use:

### Jaccard Index

```ruby
ids_a = [1, 2, 3, 4]
ids_b = [1, 2, 4]
Statly::Similarity::Jaccard.coefficient(ids_a, ids_b) # => 0.75
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
