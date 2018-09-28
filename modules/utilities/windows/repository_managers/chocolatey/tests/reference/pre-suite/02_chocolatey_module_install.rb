test_name 'MODULES-3138 - C97813 - Install Pre-suite Reference Test'

confine(:to, :platform => 'windows')

# Init
proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))

staging = { :module_name => 'puppetlabs-chocolatey' }
local = { :module_name => 'chocolatey', :source => proj_root }

# Beaker option set if "BEAKER_FORGE_HOST" environment variable is present
agents.each do |agent|
  if options[:forge_host]
    # Check to see if module version is specified.
    staging[:version] = ENV['MODULE_VERSION'] if ENV['MODULE_VERSION']
    step 'Install Chocolatey Module from Forge'
    install_dev_puppet_module_on(agent, staging)
  else
    step 'Install Chocolatey Module Dependencies'
    %w(puppetlabs-stdlib puppetlabs-powershell badgerious/windows_env).each do |dep|
      on(agent, puppet("module install #{dep}"))
	  end
    step 'Install Chocolatey Module from Local Source'
    # in CI install from staging forge, otherwise from local
    install_dev_puppet_module_on(agent, local)
  end
end
