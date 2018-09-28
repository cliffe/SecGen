require 'chocolatey_helper'
test_name 'MODULES-3037 - Add User/Password to an Existing Source'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateysource {'chocolatey':
    ensure   => present,
    location => 'https://chocolatey.org/api/v2',
    user     => 'tim',
    password => 'test',
  }
PP

# teardown
teardown do
  reset_config
end

# act
step 'Apply manifest'
apply_manifest(chocolatey_src, :catch_failures => true)

step 'Verify results'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/tim/, get_xml_value("//sources/source[@id='chocolatey']/@user", result.output).to_s, 'User did not match')
    # we are not able to verify password other than if it has a value - it will be encrypted in a non-verifyable way
    assert_match(/.+/, get_xml_value("//sources/source[@id='chocolatey']/@password", result.output).to_s, 'Password was not saved')
  end
end
