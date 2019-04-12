require 'rake'
require 'parallel_tests'

# We clear the Beaker rake tasks from spec_helper as they assume
# rspec-puppet and a certain filesystem layout
Rake::Task[:beaker_nodes].clear
Rake::Task[:beaker].clear

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance_swarm => [:spec_prep]) do |t|
  t.pattern = 'spec/acceptance_swarm'
end

namespace :acceptance_swarm do
  {
    :pooler => [
      'ubuntu-1604',
      'win-2016',
    ]
  }.each do |ns, configs|
    namespace ns.to_sym do
      configs.each do |config|
        desc "Run acceptance tests for #{ns}:#{config}"
        RSpec::Core::RakeTask.new("#{config}".to_sym => [:spec_prep]) do |t|
          ENV['BEAKER_keyfile'] = '~/.ssh/id_rsa-acceptance' if ns == :pooler
          ENV['BEAKER_setdir'] = 'spec/acceptance_swarm/nodesets'
          ENV['BEAKER_set'] = "#{ns}/#{config}"
          t.pattern = 'spec/acceptance_swarm'
        end
      end
    end
  end
end