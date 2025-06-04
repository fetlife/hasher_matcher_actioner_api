# HasherMatcherActionerApi

Wrapper around the [HasherMatcherActioner](https://github.com/facebook/ThreatExchange/tree/main/hasher-matcher-actioner) service from Meta.

This gem can be used to hash content, or search for matches for a piece of content in one or more exchange banks.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add hasher_matcher_actioner_api --github 'fetlife/hasher_matcher_actioner_api'
```

Or add to your Gemfile:

```ruby
gem "hasher_matcher_actioner_api", github: "fetlife/hasher_matcher_actioner_api"
```

## Usage

The HasherMatcherActionerApi gem provides functionality to hash URLs and files for content matching. Here are some examples of how to use it:

### Basic Setup

```ruby
require 'hasher_matcher_actioner_api'

# Configure the API client
client = HasherMatcherActionerApi::Client.new(
  base_url: 'https://api.example.com'
)
```

### Hashing URLs

```ruby
# Hash a URL with default settings
result = client.hash_url(url: 'https://example.com/image.jpg')

# Hash a URL with specific content type
result = client.hash_url(
  url: 'https://example.com/image.jpg',
  content_type: 'photo'
)

# Hash a URL with specific signal types
result = client.hash_url(
  url: 'https://example.com/image.jpg',
  signal_types: ['pdq', 'md5']
)
```

### Hashing Files

```ruby
# Hash a file from disk
File.open('path/to/image.jpg', 'rb') do |file|
  result = client.hash_file(
    file: file,
    content_type: 'photo'
  )
end

# Hash a file from memory
require 'stringio'
file = StringIO.new(file_content)
result = client.hash_file(
  file: file,
  content_type: 'photo'
)
```

### Working with Results

The hash results are returned as a `HashResult` object with attributes for each signal type:

```ruby
result = client.hash_url(url: 'https://example.com/image.jpg')

# Access individual hash values
puts result.pdq    # PDQ hash value
puts result.md5    # MD5 hash value
puts result.sha256 # SHA256 hash value
```

### Error Handling

The gem raises `ValidationError` for invalid inputs:

```ruby
begin
  result = client.hash_url(
    url: 'https://example.com/image.jpg',
    content_type: 'invalid_type'
  )
rescue HasherMatcherActionerApi::ValidationError => e
  puts "Error: #{e.message}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Releasing a New Version

To release a new version:
1. Update the version number in `version.rb`
2. Run `bundle exec rake release`

This will:
- Create a git tag for the version
- Push git commits and the created tag
- Trigger Github release workflow

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fetlife/hasher_matcher_actioner_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/fetlife/hasher_matcher_actioner_api/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HasherMatcherActionerApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fetlife/hasher_matcher_actioner_api/blob/main/CODE_OF_CONDUCT.md).
