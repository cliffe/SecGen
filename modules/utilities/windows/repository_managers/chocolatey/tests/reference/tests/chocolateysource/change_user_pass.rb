require 'chocolatey_helper'
test_name 'MODULES-3037 - Change User/Password In an Existing Source'
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
step 'Apply manifest to setup user/password'
apply_manifest(chocolatey_src, :catch_failures => true)

step 'Verify user/password setup'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/tim/, get_xml_value("//sources/source[@id='chocolatey']/@user", result.output).to_s, 'User setup did not match')
    # we are not able to verify password other than if it has a value - it will be encrypted in a non-verifyable way
    assert_match(/.+/, get_xml_value("//sources/source[@id='chocolatey']/@password", result.output).to_s, 'Password was not saved')
  end
end

# arrange
chocolatey_src_change = <<-PP
  chocolateysource {'chocolatey':
    ensure   => present,
    location => 'https://chocolatey.org/api/v2',
    user     => 'bob',
    password => 'newpass',
  }
PP

# act
step 'Apply manifest to change user/password'
apply_manifest(chocolatey_src_change, :catch_failures => true)

step 'Verify results'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/bob/, get_xml_value("//sources/source[@id='chocolatey']/@user", result.output).to_s, 'User change did not match')
  end
end
