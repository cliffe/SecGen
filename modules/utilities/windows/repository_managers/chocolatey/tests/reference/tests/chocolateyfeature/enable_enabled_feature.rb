require 'chocolatey_helper'
test_name 'MODULES-3034 - Enable Already Enabled Feature'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateyfeature {'checksumFiles':
    ensure => enabled,
  }
PP

# teardown
teardown do
  reset_config
end

#verify prior
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/true/, get_xml_value("//features/feature[@name='checksumFiles']/@enabled", result.output).to_s, 'Was not enabled by default, please adjust test to find another value.')
  end
end

# act
step 'Apply manifest'
apply_manifest(chocolatey_src, :catch_failures => true)

step 'Verify results'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/true/, get_xml_value("//features/feature[@name='checksumFiles']/@enabled", result.output).to_s, 'Was not found enabled')
  end
end
