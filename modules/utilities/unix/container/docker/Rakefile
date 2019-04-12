require 'rubygems'
require 'bundler/setup'

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_pot_generator/rake_tasks'

# These gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

begin
  require 'rubocop/rake_task'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

begin
  require 'puppet-strings/rake_tasks'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

PuppetLint.configuration.relative = true
PuppetLint.configuration.disable_80chars
PuppetLint.configuration.fail_on_warnings = true

# Forsake support for Puppet 2.6.2 for the benefit of cleaner code.
# http://puppet-lint.com/checks/class_parameter_defaults/
PuppetLint.configuration.disable_class_parameter_defaults
# http://puppet-lint.com/checks/class_inherits_from_params_class/
PuppetLint.configuration.disable_class_inherits_from_params_class
# To fix unquoted cases in spec/fixtures/modules/apt/manifests/key.pp
PuppetLint.configuration.disable_unquoted_string_in_case

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.fail_on_deprecation_notices = false
PuppetSyntax.exclude_paths = exclude_paths

begin
  require 'parallel_tests/cli'
  desc 'Run spec tests in parallel'
  task :parallel_spec do
    Rake::Task[:spec_prep].invoke
    ParallelTests::CLI.new.run('-o "--format=progress" -t rspec spec/classes spec/defines'.split)
    Rake::Task[:spec_clean].invoke
  end
  desc 'Run syntax, lint, spec and metadata tests in parallel'
  task :parallel_test => [
    :syntax,
    :lint,
    :parallel_spec,
    :metadata_lint,
  ]
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

# This fixes a backwards incompatibility in puppetlabs_spec_helper 1.1.0
if Rake::Task.task_defined?('metadata_lint')
  task :metadata => :metadata_lint
end

desc 'Run syntax, lint and  metadata tests'
task :test => [
  :syntax,
  :lint,
  :metadata_lint,
  :spec,
]
