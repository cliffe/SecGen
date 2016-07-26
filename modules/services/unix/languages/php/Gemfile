source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'rspec'
  gem 'rspec-puppet'
  gem 'rspec-puppet-facts'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-module'
  gem 'yard'
  gem 'json', '< 2'
  gem 'puppet-lint', '~> 2.0'
  gem 'puppet-lint-absolute_classname-check'
  gem 'puppet-lint-empty_string-check'
  gem 'puppet-lint-file_ensure-check'
  gem 'puppet-lint-leading_zero-check'
  gem 'puppet-lint-param-docs'
  gem 'puppet-lint-trailing_comma-check'
  gem 'puppet-lint-undef_in_function-check'
  gem 'puppet-lint-unquoted_string-check'
  gem 'puppet-lint-version_comparison-check'
  gem 'metadata-json-lint'
  gem 'puppet-blacksmith', '>= 3.1.0'
end

if facterversion = ENV['FACTER_VERSION']
  gem 'facter', facterversion
else
  gem 'facter'
end

if puppetversion = ENV['PUPPET_VERSION']
  gem 'puppet', puppetversion
else
  gem 'puppet'
end

# vim:ft=ruby
