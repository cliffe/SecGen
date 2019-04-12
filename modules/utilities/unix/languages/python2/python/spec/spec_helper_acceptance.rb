require 'beaker-rspec'

UNSUPPORTED_PLATFORMS = [ 'windows' ]

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
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
    hosts.each do |host|
      shell("rm -rf /etc/puppet/modules/python/")
      copy_module_to(host, :source => proj_root, :module_name => 'python')
      shell("/bin/touch #{default['puppetpath']}/hiera.yaml")
      on host, puppet('module install puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module install stahnma-epel'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
