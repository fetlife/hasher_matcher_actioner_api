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

### Looking Up Content

You can search for matches in banks using different methods:

#### Lookup by URL

```ruby
# Search for matches by URL
matches = client.lookup_url('https://example.com/image.jpg')

# Search with specific content type
matches = client.lookup_url(
  'https://example.com/image.jpg',
  content_type: 'photo'
)

# Search with specific signal types
matches = client.lookup_url(
  'https://example.com/image.jpg',
  signal_types: ['pdq', 'md5']
)

# Search in specific banks only
matches = client.lookup_url(
  'https://example.com/image.jpg',
  bank_names: ['bank1', 'bank2']
)
```

#### Lookup by File

```ruby
# Search for matches by file
File.open('path/to/image.jpg', 'rb') do |file|
  matches = client.lookup_file(file, content_type: 'photo')
end

# Search in specific banks only
File.open('path/to/image.jpg', 'rb') do |file|
  matches = client.lookup_file(
    file, 
    content_type: 'photo',
    bank_names: ['bank1', 'bank2']
  )
end
```

#### Lookup by Signal

```ruby
# Search for matches by hash signal
matches = client.lookup_signal(
  signal: 'abc123def456...',  # Hash value
  signal_type: 'pdq'
)

# Search for matches in specific banks only
matches = client.lookup_signal(
  signal: 'abc123def456...',  # Hash value
  signal_type: 'pdq',
  bank_names: ['bank1', 'bank2']
)

# Access match details
matches.each do |match|
  puts "Found in bank: #{match.bank_name}"
  puts "Content ID: #{match.bank_content_id}"
  puts "Distance: #{match.distance}"
end
```

### Adding Content to Banks

You can add content to banks for threat intelligence storage using two separate methods:

#### Adding Content from URLs

```ruby
# Add content from a URL
result = client.add_url_to_bank(
  bank_name: 'my_threat_bank',
  url: 'https://example.com/suspicious-image.jpg',
  content_type: 'photo'
)

# Add content from URL with metadata
metadata = {
  content_id: 'unique-content-123',
  content_uri: 'https://example.com/original-source.jpg',
  json: { source: 'user_report', priority: 'high' }
}

result = client.add_url_to_bank(
  bank_name: 'my_threat_bank',
  url: 'https://example.com/suspicious-image.jpg',
  content_type: 'photo',
  metadata: metadata
)

# Works without content_type (auto-detected)
result = client.add_url_to_bank(
  bank_name: 'my_threat_bank',
  url: 'https://example.com/suspicious-image.jpg'
)
```

#### Adding Content from Files

```ruby
# Add content from a file
File.open('path/to/suspicious-image.jpg', 'rb') do |file|
  result = client.add_file_to_bank(
    bank_name: 'my_threat_bank',
    file: file,
    content_type: 'photo'
  )
end

# Add content from file with metadata
metadata = {
  content_id: 'unique-content-456',
  content_uri: 'https://example.com/original-source.jpg',
  json: { source: 'file_upload', priority: 'high' }
}

File.open('path/to/suspicious-image.jpg', 'rb') do |file|
  result = client.add_file_to_bank(
    bank_name: 'my_threat_bank',
    file: file,
    content_type: 'photo',
    metadata: metadata
  )
end

# Access the result
puts result.id          # Content ID in the bank
puts result.signals     # Generated hash signals
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


## Using the local gem in another project

To use this gem locally during development in another project:

1. Configure the local gem path:
```bash
bundle config set local.hasher_matcher_actioner_api ../hasher_matcher_actioner_api
bundle config disable_local_branch_check true
```

2. Add the gem to your project's Gemfile:
```ruby
gem "hasher_matcher_actioner_api", git: "https://github.com/fetlife/hasher_matcher_actioner_api", branch: 'main'
```

3. Run bundle install:
```bash
bundle install
```

Now you can use the gem in your project and any changes you make to the local gem will be immediately available without needing to rebuild or reinstall.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fetlife/hasher_matcher_actioner_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/fetlife/hasher_matcher_actioner_api/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HasherMatcherActionerApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fetlife/hasher_matcher_actioner_api/blob/main/CODE_OF_CONDUCT.md).
