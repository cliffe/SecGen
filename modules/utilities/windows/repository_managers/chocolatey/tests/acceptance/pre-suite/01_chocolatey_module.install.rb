test_name 'MODULES-3138 - C97814 - Install Pre-suite Acceptance Test'

# Beaker option set if "BEAKER_FORGE_HOST" environment variable is present
staging = { :module_name => 'puppetlabs-chocolatey' }
if options[:forge_host]
  # Check to see if module version is specified.
  staging[:version] = ENV['MODULE_VERSION'] if ENV['MODULE_VERSION']
  step 'Install Chocolatey Module from Forge'
  install_dev_puppet_module_on(master, staging)
else
  step 'Install Chocolatey Module Dependencies'
  %w(puppetlabs-stdlib puppetlabs-powershell badgerious/windows_env).each do |dep|
    on(master, puppet("module install #{dep}"))
  end
end

step 'Install Chocolatey Module'
proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))
local = { :module_name => 'chocolatey', :source => proj_root}

# Check to see if module version is specified.
staging[:version] = ENV['MODULE_VERSION'] if ENV['MODULE_VERSION']

# in CI install from staging forge, otherwise from local
install_dev_puppet_module_on(master, local)
