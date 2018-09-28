 require 'puppetlabs_spec_helper/rake_tasks'
 require 'puppet-lint/tasks/puppet-lint'
 require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
begin
  require 'beaker/tasks/test'
rescue LoadError
 #Do nothing, rescue for Windows as beaker does not work and will not be installed
end

#Due to puppet-lint not ignoring tests folder or the ignore paths attribute
#we have to ignore many things
# #Due to bug in puppet-lint we have to clear and redo the lint tasks to achieve ignore paths
 Rake::Task[:lint].clear
 PuppetLint::RakeTask.new(:lint) do |config|
   config.pattern = 'manifests/**/*.pp'
   config.fail_on_warnings = true
   config.disable_checks = [
       '80chars',
       'class_inherits_from_params_class',
       'class_parameter_defaults',
       'documentation',
       'single_quote_string_with_variables']
   config.ignore_paths = ["tests/*.pp", "spec/**/*.pp", "pkg/**/*.pp"]
 end

task :default => [:test]

desc 'Run RSpec'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/{unit}/**/*.rb'
  #t.rspec_opts = ['--color']
end

desc 'Generate code coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end
