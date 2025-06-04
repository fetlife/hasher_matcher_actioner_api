# frozen_string_literal: true

require_relative "lib/hasher_matcher_actioner_api/version"

Gem::Specification.new do |spec|
  spec.name = "hasher_matcher_actioner_api"
  spec.version = HasherMatcherActionerApi::VERSION
  spec.authors = ["Pez Cuckow"]
  spec.email = ["email@pezcuckow.com"]

  spec.summary = "API client for the Hasher Matcher Actioner service"
  spec.description = "A Ruby client for interacting with the Hasher Matcher Actioner API from Meta."
  spec.homepage = "https://github.com/FetLife/hasher_matcher_actioner_api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fetlife/hasher_matcher_actioner_api"
  spec.metadata["changelog_uri"] = "https://github.com/FetLife/threatexchange/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.13"
  spec.add_dependency "faraday-retry", "~> 2.2"
  spec.add_dependency "faraday-multipart", "~> 1.1"
  spec.add_dependency "json", "~> 2.12"
  spec.add_dependency "dry-struct", "~> 1.8"
  spec.add_dependency "dry-types", "~> 1.8"
  spec.add_dependency "marcel", "~> 1.0"
end
