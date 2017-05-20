require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

# blacksmith is broken with ruby 1.8.7
if Gem::Version.new(RUBY_VERSION) > Gem::Version.new('1.8.7')
  # blacksmith isn't always present, e.g. on Travis with --without development
  begin
    require 'puppet_blacksmith/rake_tasks'
    Blacksmith::RakeTask.new do |t|
      t.tag_pattern = "%s"
    end
  rescue LoadError
  end
end

Rake::Task['lint'].clear

PuppetLint::RakeTask.new :lint do |config|
  config.pattern = 'manifests/**/*.pp'
  config.fail_on_warnings = true
end

task :default => [:validate, :lint, :spec]