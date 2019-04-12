# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  puppetversion = ENV['PUPPET_VERSION'] || '~> 4.9'

  gem 'puppet', puppetversion
  gem 'rake'

  install_if(Gem::Version.new(puppetversion.split(' ').last) < Gem::Version.new(4.9)) do
    gem 'semantic_puppet'
  end

  gem 'infrataster'
  gem 'metadata-json-lint'
  gem 'puppet-strings'
  gem 'puppetlabs_spec_helper', '>= 2.7.0'
  gem 'rspec', '~> 3.5'
  gem 'rspec-puppet', '>=2.3.0'
  gem 'rspec-puppet-facts'
  gem 'rspec-puppet-utils'
  gem 'rspec-retry'
  # Required to test against Ruby 1.9
  gem 'rubocop', '~> 0.41.2'
  gem 'safe_yaml', '~> 1.0.4'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
  gem 'xmlrpc'

  gem 'puppet-lint-absolute_classname-check'
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check'
  gem 'puppet-lint-leading_zero-check'
  gem 'puppet-lint-param-docs'
  gem 'puppet-lint-resource_reference_syntax'
  gem 'puppet-lint-trailing_comma-check'
  gem 'puppet-lint-unquoted_string-check'
  gem 'puppet-lint-version_comparison-check'

  gem 'json_pure', '<= 2.0.1' if RUBY_VERSION < '2.0.0'
end

group :development do
  gem 'guard-bundler',      require: false
  gem 'guard-rake'          if RUBY_VERSION >= '2.2.5' # per dependency https://rubygems.org/gems/ruby_dep
  gem 'guard-rspec',        require: false
  gem 'puppet-blacksmith'
  gem 'travis'              if RUBY_VERSION >= '2.1.0'
  gem 'travis-lint'         if RUBY_VERSION >= '2.1.0'
end

group :system_tests do
  gem 'beaker'
  gem 'beaker-puppet_install_helper', '0.6.0'
  gem 'beaker-rspec'
end
