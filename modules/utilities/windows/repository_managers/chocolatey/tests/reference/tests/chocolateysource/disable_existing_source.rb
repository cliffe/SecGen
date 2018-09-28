require 'chocolatey_helper'
test_name 'MODULES-3037 - Disable an Existing Source'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateysource {'chocolatey':
    ensure   => disabled,
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
    assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@disabled", result.output).to_s, 'Disabled did not match')
  end
end
