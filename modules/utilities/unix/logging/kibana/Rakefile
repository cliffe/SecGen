# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet/version'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'metadata-json-lint/rake_task'
require 'rubocop/rake_task'
require 'puppet-strings'
require 'puppet-strings/tasks'
require_relative 'spec/spec_utilities'
require 'nokogiri'
require 'open-uri'

oss_package = ENV['OSS_PACKAGE'] and ENV['OSS_PACKAGE'] == 'true'

def v(ver)
  Gem::Version.new(ver)
end

if v(Puppet.version) >= v('4.9')
  require 'semantic_puppet'
elsif v(Puppet.version) >= v('3.6') && v(Puppet.version) < v('4.9')
  require 'puppet/vendor/semantic/lib/semantic'
end

# These gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

exclude_paths = [
  'coverage/**/*',
  'doc/**/*',
  'pkg/**/*',
  'vendor/**/*',
  'spec/**/*'
]

Rake::Task[:lint].clear

PuppetLint.configuration.relative = true
PuppetLint.configuration.disable_80chars
PuppetLint.configuration.disable_class_inherits_from_params_class
PuppetLint.configuration.disable_class_parameter_defaults
PuppetLint.configuration.fail_on_warnings = true

PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = exclude_paths
end

PuppetSyntax.exclude_paths = exclude_paths

task :beaker => :spec_prep

desc 'Run all non-acceptance rspec tests.'
RSpec::Core::RakeTask.new(:spec_unit) do |t|
  t.pattern = 'spec/{classes,templates,unit}/**/*_spec.rb'
end
task :spec_unit => :spec_prep

desc 'Run syntax, lint, and spec tests.'
task :test => [
  :lint,
  :rubocop,
  :validate,
  :spec_unit
]

desc 'remove outdated module fixtures'
task :spec_prune do
  mods = 'spec/fixtures/modules'
  fixtures = YAML.load_file '.fixtures.yml'
  fixtures['fixtures']['forge_modules'].each do |mod, params|
    next unless params.is_a? Hash \
      and params.key? 'ref' \
      and File.exist? "#{mods}/#{mod}"

    metadata = JSON.parse(File.read("#{mods}/#{mod}/metadata.json"))
    FileUtils.rm_rf "#{mods}/#{mod}" unless metadata['version'] == params['ref']
  end
end
task :spec_prep => [:spec_prune]

# Plumbing for snapshot tests
desc 'Run the snapshot tests'
RSpec::Core::RakeTask.new('beaker:snapshot') do |task|
  task.rspec_opts = ['--color']
  task.pattern = 'spec/acceptance/tests/snapshot.rb'

  if Rake::Task.task_defined? 'artifact:snapshot:not_found'
    puts 'No snapshot artifacts found, skipping snapshot tests.'
    exit(0)
  end
end

beaker_node_sets.each do |node|
  desc "Run the snapshot tests against the #{node} nodeset"
  task "beaker:#{node}:snapshot" => %w[
    spec_prep
    artifact:snapshot:deb
    artifact:snapshot:rpm
  ] do
    ENV['BEAKER_set'] = node
    Rake::Task['beaker:snapshot'].reenable
    Rake::Task['beaker:snapshot'].invoke
  end
end

namespace :artifact do
  desc 'Fetch specific installation artifacts'
  task :fetch, [:version] do |_t, args|
    [
      "https://artifacts.elastic.co/downloads/kibana/kibana-#{args[:version]}.rpm",
      "https://artifacts.elastic.co/downloads/kibana/kibana-#{args[:version]}.deb"
    ].each do |package|
      get package, artifact(package)
    end
  end

  namespace :snapshot do
    catalog = JSON.parse(
      open('https://artifacts-api.elastic.co/v1/branches/6.x').read
    )['latest']
    ENV['snapshot_version'] = catalog['version']

    downloads = catalog['projects']['kibana']['packages'].select do |pkg, _|
      pkg =~ /(?:deb|rpm)/ and (oss_package ? pkg =~ /oss/ : pkg !~ /oss/)
    end.map do |package, urls|
      [package.split('.').last, urls]
    end.to_h

    # We end up with something like:
    # {
    #   'rpm' => {'url' => 'https://...', 'sha_url' => 'https://...'},
    #   'deb' => {'url' => 'https://...', 'sha_url' => 'https://...'}
    # }
    # Note that checksums are currently broken on the Elastic unified release
    # side; once they start working we can verify them.

    if downloads.empty?
      puts 'No snapshot release available; skipping snapshot download'
      %w[deb rpm].each { |ext| task ext }
      task 'not_found'
    else
      # Download snapshot files
      downloads.each_pair do |extension, urls|
        filename = artifact urls['url']
        checksum = artifact urls['sha_url']
        link = artifact "kibana-snapshot.#{extension}"
        FileUtils.rm link if File.exist? link

        task extension => link
        file link => filename do
          unless File.exist?(link) and File.symlink?(link) \
              and File.readlink(link) == filename
            File.delete link if File.exist? link
            File.symlink File.basename(filename), link
          end
        end

        # file filename => checksum do
        file filename do
          get urls['url'], filename
        end

        task checksum do
          File.delete checksum if File.exist? checksum
          get urls['sha_url'], checksum
        end
      end
    end
  end

  desc 'Purge fetched artifacts'
  task :clean do
    FileUtils.rm_rf(Dir.glob('spec/fixtures/artifacts/*'))
  end
end
