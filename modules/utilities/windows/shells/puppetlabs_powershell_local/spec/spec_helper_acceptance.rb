require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

UNSUPPORTED_PLATFORMS = ['debian', 'ubuntu', 'Solaris']
FUTURE_PARSER = ENV['FUTURE_PARSER'] == 'true' || false

run_puppet_install_helper

unless ENV['MODULE_provision'] == 'no'

  on default, "mkdir -p #{default['distmoduledir']}/powershell"
  result = on default, "echo #{default['distmoduledir']}/powershell"
  target = result.raw_output.chomp
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  %w(lib metadata.json).each do |file|
    scp_to default, "#{proj_root}/#{file}", target
  end
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    shell("/bin/touch #{default['puppetpath']}/hiera.yaml")
  end
  c.after :suite do
    absent_files = 'file{["c:/services.txt","c:/process.txt","c:/try_success.txt","c:/catch_shouldntexist.txt","c:/try_shouldntexist.txt","c:/catch_success.txt"]: ensure => absent }'
    apply_manifest(absent_files)
  end
end

