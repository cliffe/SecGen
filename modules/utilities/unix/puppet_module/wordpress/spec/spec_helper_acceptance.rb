require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  if hosts.first.is_pe?
    install_pe
  else
    install_puppet({ :version        => '3.6.2',
                     :facter_version => '2.1.0',
                     :hiera_version  => '1.3.4',
                     :default_action => 'gem_install' })
    hosts.each {|h| on h, "/bin/echo '' > #{h['hieraconf']}" }
  end
  hosts.each do |host|
    on host, "mkdir -p #{host['distmoduledir']}"
    on host, puppet('module','install','puppetlabs-stdlib'), :acceptable_exit_codes => [0,1]
    on host, puppet('module','install','puppetlabs-concat'), :acceptable_exit_codes => [0,1]
    on host, puppet('module','install','puppetlabs-mysql' ), :acceptable_exit_codes => [0,1]
    on host, puppet('module','install','puppetlabs-apache'), :acceptable_exit_codes => [0,1]
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'wordpress')
  end
end
