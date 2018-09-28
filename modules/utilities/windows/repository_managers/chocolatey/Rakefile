require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet'

begin
  require 'beaker/tasks/test' unless RUBY_PLATFORM =~ /win32/
rescue LoadError
  #Do nothing, only installed with system_tests group
end


# If puppet does not support symlinks (e.g., puppet <= 3.5) we cannot use
# puppetlabs_spec_helper's `rake spec` task because it requires symlink
# support. Redefine `rake spec` to avoid calling `rake spec_prep` (requires
# symlinks to place fixtures) and restrict the pattern match only files under
# the 'unit' directory (tests in other dirs require fixtures).
if Puppet::Util::Platform.windows? and !Puppet::FileSystem.respond_to?(:symlink)
  ENV["SPEC"] = "./spec/{unit,integration}/**/*_spec.rb"
  Rake::Task[:spec].clear if Rake::Task.task_defined?(:spec)
  task :spec do
    Rake::Task[:spec_standalone].invoke
    Rake::Task[:spec_clean].invoke
  end
end

# These lint exclusions are in puppetlabs_spec_helper but needs a version above 0.10.3
# Line length test is 80 chars in puppet-lint 1.1.0
PuppetLint.configuration.send('disable_80chars')
# Line length test is 140 chars in puppet-lint 2.x
PuppetLint.configuration.send('disable_140chars')

task :default => [:spec]

desc 'Generate code coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end


platform = ENV["PLATFORM"]

# Create the directory, if it exists already you'll get an error, but this should not stop the execution
begin
  sh 'mkdir tests/configs'
rescue => e
  puts e.message
end

desc 'Executes reference tests (agent only) intended for use in CI'
task :reference_tests do
  command = "bundle exec beaker-hostgenerator --global-config {masterless=true} #{platform} > tests/configs/#{platform}" # should we assume the "configs" directory is present?
  sh command

  command =<<-EOS
bundle exec beaker                          \
    --debug                                 \
    --preserve-hosts never                  \
    --config tests/configs/$PLATFORM        \
    --keyfile ~/.ssh/id_rsa-acceptance      \
    --load-path tests/lib                   \
    --type aio                              \
    --pre-suite tests/reference/pre-suite   \
    --tests tests/reference/tests
    EOS
  sh command
end

desc 'Executes acceptance tests (master and agent) intended for use in CI'
task :acceptance_tests do
  command = "bundle exec beaker-hostgenerator #{platform} > tests/configs/#{platform}"
  sh command

  command =<<-EOS
bundle exec beaker                          \
    --debug                                 \
    --preserve-hosts never                  \
    --config tests/configs/$PLATFORM        \
    --keyfile ~/.ssh/id_rsa-acceptance      \
    --load-path tests/lib                   \
    --pre-suite tests/acceptance/pre-suite  \
    --tests tests/acceptance/tests
    EOS
  sh command
end

task :acceptance_tests => [:basic_enviroment_variable_check, :acceptance_enviroment_varible_check]
task :reference_tests => [:basic_enviroment_variable_check]

task :basic_enviroment_variable_check do
  abort('PLATFORM variable not present, aborting test.') unless ENV["PLATFORM"]
  abort('MODULE_VERSION variable not present, aborting test.') unless ENV["MODULE_VERSION"]
end

task :acceptance_enviroment_varible_check do
  if ENV["BEAKER_PE_DIR"] && ENV["PE_DIST_DIR"]
      abort('Either BEAKER_PE_DIR or PE_DIST_DIR variable should be set but not both, aborting test.')
  end
  if !ENV["BEAKER_PE_DIR"] && !ENV["PE_DIST_DIR"]
      abort('Neither BEAKER_PE_DIR or PE_DIST_DIR variable is set, aborting test.')
  end
end

