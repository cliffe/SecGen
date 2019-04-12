require 'rake'
require 'parallel_tests'

# We clear the Beaker rake tasks from spec_helper as they assume
# rspec-puppet and a certain filesystem layout
Rake::Task[:beaker_nodes].clear
Rake::Task[:beaker].clear

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance => [:spec_prep]) do |t|
  t.pattern = 'spec/acceptance'
end

namespace :acceptance do
  {
    :vagrant => [
       'centos-70-x64',
       'debian-81-x64',
       'ubuntu-1404-x64',
       'ubuntu-1604-x64',
    ],
    :pooler => [
      'centos7',
      'rhel7',
      'ubuntu-1404',
      'ubuntu-1604',
      'ubuntu-1610',
      'win-2016',
    ]
  }.each do |ns, configs|
    namespace ns.to_sym do
      configs.each do |config|
        desc "Run acceptance tests for #{ns}:#{config}"
        RSpec::Core::RakeTask.new("#{config}".to_sym => [:spec_prep]) do |t|
          ENV['BEAKER_keyfile'] = '~/.ssh/id_rsa-acceptance' if ns == :pooler
          ENV['BEAKER_set'] = "#{ns}/#{config}"
          t.pattern = 'spec/acceptance'
        end
      end
    end
  end
end