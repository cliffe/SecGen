source 'https://rubygems.org'

group :test do
  gem 'rest-client', '~> 1.6.8', :require => false, :platforms => :ruby_18
end

group :rake, :test do
  gem 'puppetlabs_spec_helper', '>=0.8.2', :require => false
  gem 'puppet-blacksmith',       :require => false
  gem 'beaker',                  :require => false
  gem 'beaker-rspec',            :require => false
end

group :rake do
  gem 'rspec-puppet', '>=2.1.0', :require => false
  gem 'rake',         '>=0.9.2.2'
  gem 'puppet-lint',  '>=1.0.1'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
