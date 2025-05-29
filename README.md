# HasherMatcherActionerApi

[![Gem Version](https://img.shields.io/gem/v/hasher_matcher_actioner_api)](https://rubygems.org/gems/hasher_matcher_actioner_api)
[![Gem Downloads](https://img.shields.io/gem/dt/hasher_matcher_actioner_api)](https://www.ruby-toolbox.com/projects/hasher_matcher_actioner_api)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/fetlife/hasher_matcher_actioner_api/ci.yml)](https://github.com/fetlife/hasher_matcher_actioner_api/actions/workflows/ci.yml)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/fetlife/hasher_matcher_actioner_api)](https://codeclimate.com/github/fetlife/hasher_matcher_actioner_api)

Wrapper around the [HasherMatcherActioner](https://github.com/facebook/ThreatExchange/tree/main/hasher-matcher-actioner) service.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

The HasherMatcherActionerApi gem provides functionality to hash URLs and files for content matching. Here are some examples of how to use it:

### Basic Setup

```ruby
require 'hasher_matcher_actioner_api'

# Configure the API client
client = HasherMatcherActionerApi::Client.new(
  api_key: 'your_api_key',
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
  content_type: 'image'
)

# Hash a URL with specific signal types
result = client.hash_url(
  url: 'https://example.com/image.jpg',
  types: ['pdq', 'md5']
)
```

### Hashing Files

```ruby
# Hash a file from disk
File.open('path/to/image.jpg', 'rb') do |file|
  result = client.hash_file(
    file: file,
    content_type: 'image'
  )
end

# Hash a file from memory
require 'stringio'
file = StringIO.new(file_content)
result = client.hash_file(
  file: file,
  content_type: 'image'
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

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fetlife/hasher_matcher_actioner_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/fetlife/hasher_matcher_actioner_api/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HasherMatcherActionerApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fetlife/hasher_matcher_actioner_api/blob/main/CODE_OF_CONDUCT.md).
