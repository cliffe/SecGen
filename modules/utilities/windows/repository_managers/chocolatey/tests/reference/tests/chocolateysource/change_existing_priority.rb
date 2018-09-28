require 'chocolatey_helper'
test_name 'MODULES-3037 - Change Existing Priority'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateysource {'chocolatey':
    ensure   => present,
    location => 'https://chocolatey.org/api/v2',
    priority => 1,
  }
PP

# teardown
teardown do
  reset_config
end

# act
step 'Apply manifest to set priority'
apply_manifest(chocolatey_src, :catch_failures => true)

step 'Verify priority setup was added'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/1/, get_xml_value("//sources/source[@id='chocolatey']/@priority", result.output).to_s, 'Priority setup did not match')
  end
end

# arrange
chocolatey_src_change = <<-PP
  chocolateysource {'chocolatey':
    ensure   => present,
    location => 'https://chocolatey.org/api/v2',
    priority => 5,
  }
PP

# act
step 'Apply manifest to change priority'
apply_manifest(chocolatey_src_change, :catch_failures => true)

step 'Verify results'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/5/, get_xml_value("//sources/source[@id='chocolatey']/@priority", result.output).to_s, 'Priority change did not match')
  end
end

