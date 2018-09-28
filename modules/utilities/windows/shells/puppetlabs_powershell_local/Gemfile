source ENV['GEM_SOURCE'] || "https://rubygems.org"

# Determines what type of gem is requested based on place_or_version.
def gem_type(place_or_version)
  if place_or_version =~ /^git:/
    :git
  elsif place_or_version =~ /^file:/
    :file
  else
    :gem
  end
end

# Find a location or specific version for a gem. place_or_version can be a
# version, which is most often used. It can also be git, which is specified as
# `git://somewhere.git#branch`. You can also use a file source location, which
# is specified as `file://some/location/on/disk`.
def location_for(place_or_version, fake_version = nil)
  if place_or_version =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place_or_version =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place_or_version, { :require => false }]
  end
end

# The following gems are not included by default as they require DevKit on Windows.
# You should probably include them in a Gemfile.local or a ~/.gemfile
#gem 'pry' #this may already be included in the gemfile
#gem 'pry-stack_explorer', :require => false
#if RUBY_VERSION =~ /^2/
#  gem 'pry-byebug'
#else
#  gem 'pry-debugger'
#end

group :development do
  gem 'rake',                                :require => false
  gem 'rspec', '~>3.0',                      :require => false
  gem 'puppet-lint',                         :require => false
  gem 'puppetlabs_spec_helper', '~>0.10.3',  :require => false
  gem 'puppet_facts',                        :require => false
  gem 'mocha', '~>0.10.5',                   :require => false
  gem 'pry',                                 :require => false
end

group :system_tests do
  gem 'beaker-rspec', *location_for(ENV['BEAKER_RSPEC_VERSION'] || '~> 5.1')
  gem 'beaker', *location_for(ENV['BEAKER_VERSION'] || '~> 2.20')
  gem 'beaker-puppet_install_helper',  :require => false
end

# The recommendation is for PROJECT_GEM_VERSION, although there are older ways
# of referencing these. Add them all for compatibility reasons. We'll remove
# later when no issues are known. We'll prefer them in the right order.
puppetversion = ENV['PUPPET_GEM_VERSION'] || ENV['GEM_PUPPET_VERSION'] || ENV['PUPPET_LOCATION'] || '>= 0'
gem 'puppet', *location_for(puppetversion)

# json_pure 2.0.2 added a requirement on ruby >= 2. We pin to json_pure 2.0.1
# if using ruby 1.x
gem 'json_pure', '<=2.0.1', :require => false if RUBY_VERSION =~ /^1\./

# Only explicitly specify Facter/Hiera if a version has been specified.
# Otherwise it can lead to strange bundler behavior. If you are seeing weird
# gem resolution behavior, try setting `DEBUG_RESOLVER` environment variable
# to `1` and then run bundle install.
facterversion = ENV['FACTER_GEM_VERSION'] || ENV['GEM_FACTER_VERSION'] || ENV['FACTER_LOCATION']
gem "facter", *location_for(facterversion) if facterversion
hieraversion = ENV['HIERA_GEM_VERSION'] || ENV['GEM_HIERA_VERSION'] || ENV['HIERA_LOCATION']
gem "hiera", *location_for(hieraversion) if hieraversion

# For Windows dependencies, these could be required based on the version of
# Puppet you are requiring. Anything greater than v3.5.0 is going to have
# Windows-specific dependencies dictated by the gem itself. The other scenario
# is when you are faking out Puppet to use a local file path / git path.
explicitly_require_windows_gems = false
puppet_gem_location = gem_type(puppetversion)
# This is not a perfect answer to the version check
if puppet_gem_location != :gem || puppetversion < '3.5.0'
  if Gem::Platform.local.os == 'mingw32'
    explicitly_require_windows_gems = true
  end

  if puppet_gem_location == :gem
    # If facterversion hasn't been specified and we are
    # looking for a Puppet Gem version less than 3.5.0, we
    # need to ensure we get a good Facter for specs.
    gem "facter",">= 1.6.11","<= 1.7.5",:require => false unless facterversion
    # If hieraversion hasn't been specified and we are
    # looking for a Puppet Gem version less than 3.5.0, we
    # need to ensure we get a good Hiera for specs.
    gem "hiera",">= 1.0.0","<= 1.3.0",:require => false unless hieraversion
  end
end

if explicitly_require_windows_gems
  # This also means Puppet Gem less than 3.5.0 - this has been tested back
  # to 3.0.0. Any further back is likely not supported.
  if puppet_gem_location == :gem
    gem "ffi", "1.9.0",                          :require => false
    gem "win32-eventlog", "0.5.3","<= 0.6.5",    :require => false
    gem "win32-process", "0.6.5","<= 0.7.5",     :require => false
    gem "win32-security", "~> 0.1.2","<= 0.2.5", :require => false
    gem "win32-service", "0.7.2","<= 0.8.8",     :require => false
    gem "minitar", "0.5.4",                      :require => false
  else
    gem "ffi", "~> 1.9.0",                       :require => false
    gem "win32-eventlog", "~> 0.5","<= 0.6.5",   :require => false
    gem "win32-process", "~> 0.6","<= 0.7.5",    :require => false
    gem "win32-security", "~> 0.1","<= 0.2.5",   :require => false
    gem "win32-service", "~> 0.7","<= 0.8.8",    :require => false
    gem "minitar", "~> 0.5.4",                   :require => false
  end

  gem "win32-dir", "~> 0.3","<= 0.4.9", :require => false
  gem "win32console", "1.3.2",          :require => false if RUBY_VERSION =~ /^1\./

  # Puppet less than 3.7.0 requires these.
  # Puppet 3.5.0+ will control the actual requirements.
  # These are listed in formats that work with all versions of
  # Puppet from 3.0.0 to 3.6.x. After that, these were no longer used.
  # We do not want to allow newer versions than what came out after
  # 3.6.x to be used as they constitute some risk in breaking older
  # functionality. So we set these to exact versions.
  gem "sys-admin", "1.5.6",             :require => false
  gem "win32-api", "1.4.8",             :require => false
  gem "win32-taskscheduler", "0.2.2",   :require => false
  gem "windows-api", "0.4.3",           :require => false
  gem "windows-pr",  "1.2.3",           :require => false
else
  if Gem::Platform.local.os == 'mingw32'
    # If we're using a Puppet gem on windows, which handles its own win32-xxx gem dependencies (Pup 3.5.0 and above), set maximum versions
    # Required due to PUP-6445
    gem "win32-dir", "<= 0.4.9",        :require => false
    gem "win32-eventlog", "<= 0.6.5",   :require => false
    gem "win32-process", "<= 0.7.5",    :require => false
    gem "win32-security", "<= 0.2.5",   :require => false
    gem "win32-service", "<= 0.8.8",    :require => false
  end
end

# Evaluate Gemfile.local if it exists
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# Evaluate ~/.gemfile if it exists
if File.exists?(File.join(Dir.home, '.gemfile'))
  eval(File.read(File.join(Dir.home, '.gemfile')), binding)
end

# vim:ft=ruby
