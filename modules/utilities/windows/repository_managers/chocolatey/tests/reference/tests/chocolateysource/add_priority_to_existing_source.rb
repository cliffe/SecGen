require 'chocolatey_helper'
test_name 'MODULES-3037 - Add Priority to an Existing Source'
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
step 'Apply manifest'
apply_manifest(chocolatey_src, :catch_failures => true)

step 'Verify results'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/1/, get_xml_value("//sources/source[@id='chocolatey']/@priority", result.output).to_s, 'Priority did not match')
  end
end
