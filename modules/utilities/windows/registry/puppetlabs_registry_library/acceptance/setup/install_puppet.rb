require 'beaker/puppet_install_helper'

run_puppet_install_helper

test_name "Installing Puppet Modules" do
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  hosts.each do |host|
    if host['platform'] =~ /windows/
      on host, "mkdir -p #{host['distmoduledir']}/registry"
      target = (on host, "echo #{host['distmoduledir']}/registry").raw_output.chomp

      %w(lib manifests metadata.json).each do |file|
        scp_to host, "#{proj_root}/#{file}", target
      end
      on host, 'curl -k -o c:/puppetlabs-stdlib-4.6.0.tar.gz https://forgeapi.puppetlabs.com/v3/files/puppetlabs-stdlib-4.6.0.tar.gz'
      on host, puppet('module install c:/puppetlabs-stdlib-4.6.0.tar.gz --force --ignore-dependencies'), {:acceptable_exit_codes => [0, 1]}
    end
  end
end
