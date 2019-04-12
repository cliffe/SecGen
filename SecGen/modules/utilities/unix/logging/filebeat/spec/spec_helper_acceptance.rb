require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

UNSUPPORTED_PLATFORMS = ['aix', 'Solaris', 'BSD'].freeze

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(source: module_root, module_name: 'filebeat')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'puppetlabs-apt'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'puppetlabs-powershell'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'lwf-remote_file'), acceptable_exit_codes: [0, 1]
    end
  end
end

shared_examples 'an idempotent resource' do
  it 'apply with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'apply a second time without changes', :skip_pup_5016 do
    apply_manifest(pp, catch_changes: true)
  end
end
