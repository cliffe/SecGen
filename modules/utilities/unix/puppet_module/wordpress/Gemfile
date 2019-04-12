source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place_or_version, fake_version = nil)
  if place_or_version =~ %r{\A(git[:@][^#]*)#(.*)}
    [fake_version, { git: Regexp.last_match(1), branch: Regexp.last_match(2), require: false }].compact
  elsif place_or_version =~ %r{\Afile:\/\/(.*)}
    ['>= 0', { path: File.expand_path(Regexp.last_match(1)), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

def gem_type(place_or_version)
  if place_or_version =~ %r{\Agit[:@]}
    :git
  elsif !place_or_version.nil? && place_or_version.start_with?('file:')
    :file
  else
    :gem
  end
end

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = ruby_version_segments[0..1].join('.')

group :development do
  gem "fast_gettext", '1.1.0',                         require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.1.0')
  gem "fast_gettext",                                  require: false if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.1.0')
  gem "json_pure", '<= 2.0.1',                         require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.0.0')
  gem "json", '= 1.8.1',                               require: false if Gem::Version.new(RUBY_VERSION.dup) == Gem::Version.new('2.1.9')
  gem "puppet-module-posix-default-r#{minor_version}", require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}",     require: false, platforms: [:ruby]
  gem "puppet-module-win-default-r#{minor_version}",   require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "puppet-module-win-dev-r#{minor_version}",       require: false, platforms: [:mswin, :mingw, :x64_mingw]
end

puppet_version = ENV['PUPPET_GEM_VERSION']
puppet_type = gem_type(puppet_version)
facter_version = ENV['FACTER_GEM_VERSION']
hiera_version = ENV['HIERA_GEM_VERSION']

def puppet_older_than?(version)
  puppet_version = ENV['PUPPET_GEM_VERSION']
  !puppet_version.nil? &&
    Gem::Version.correct?(puppet_version) &&
    Gem::Requirement.new("< #{version}").satisfied_by?(Gem::Version.new(puppet_version.dup))
end

gems = {}

gems['puppet'] = location_for(puppet_version)

# If facter or hiera versions have been specified via the environment
# variables, use those versions. If not, and if the puppet version is < 3.5.0,
# use known good versions of both for puppet < 3.5.0.
if facter_version
  gems['facter'] = location_for(facter_version)
elsif puppet_type == :gem && puppet_older_than?('3.5.0')
  gems['facter'] = ['>= 1.6.11', '<= 1.7.5', require: false]
end

if hiera_version
  gems['hiera'] = location_for(ENV['HIERA_GEM_VERSION'])
elsif puppet_type == :gem && puppet_older_than?('3.5.0')
  gems['hiera'] = ['>= 1.0.0', '<= 1.3.0', require: false]
end

if Gem.win_platform? && (puppet_type != :gem || puppet_older_than?('3.5.0'))
  # For Puppet gems < 3.5.0 (tested as far back as 3.0.0) on Windows
  if puppet_type == :gem
    gems['ffi'] =            ['1.9.0',                require: false]
    gems['minitar'] =        ['0.5.4',                require: false]
    gems['win32-eventlog'] = ['0.5.3',    '<= 0.6.5', require: false]
    gems['win32-process'] =  ['0.6.5',    '<= 0.7.5', require: false]
    gems['win32-security'] = ['~> 0.1.2', '<= 0.2.5', require: false]
    gems['win32-service'] =  ['0.7.2',    '<= 0.8.8', require: false]
  else
    gems['ffi'] =            ['~> 1.9.0',             require: false]
    gems['minitar'] =        ['~> 0.5.4',             require: false]
    gems['win32-eventlog'] = ['~> 0.5',   '<= 0.6.5', require: false]
    gems['win32-process'] =  ['~> 0.6',   '<= 0.7.5', require: false]
    gems['win32-security'] = ['~> 0.1',   '<= 0.2.5', require: false]
    gems['win32-service'] =  ['~> 0.7',   '<= 0.8.8', require: false]
  end

  gems['win32-dir'] = ['~> 0.3', '<= 0.4.9', require: false]

  if RUBY_VERSION.start_with?('1.')
    gems['win32console'] = ['1.3.2', require: false]
    # sys-admin was removed in Puppet 3.7.0 and doesn't compile under Ruby 2.x
    gems['sys-admin'] =    ['1.5.6', require: false]
  end

  # Puppet < 3.7.0 requires these.
  # Puppet >= 3.5.0 gem includes these as requirements.
  # The following versions are tested to work with 3.0.0 <= puppet < 3.7.0.
  gems['win32-api'] =           ['1.4.8', require: false]
  gems['win32-taskscheduler'] = ['0.2.2', require: false]
  gems['windows-api'] =         ['0.4.3', require: false]
  gems['windows-pr'] =          ['1.2.3', require: false]
elsif Gem.win_platform?
  # If we're using a Puppet gem on Windows which handles its own win32-xxx gem
  # dependencies (>= 3.5.0), set the maximum versions (see PUP-6445).
  gems['win32-dir'] =      ['<= 0.4.9', require: false]
  gems['win32-eventlog'] = ['<= 0.6.5', require: false]
  gems['win32-process'] =  ['<= 0.7.5', require: false]
  gems['win32-security'] = ['<= 0.2.5', require: false]
  gems['win32-service'] =  ['<= 0.8.8', require: false]
end

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
