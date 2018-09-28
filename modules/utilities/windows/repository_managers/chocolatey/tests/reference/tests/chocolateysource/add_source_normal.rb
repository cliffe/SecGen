require 'chocolatey_helper'
test_name 'MODULES-3037 - Add Source Happy Path'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateysource {'test':
    ensure   => present,
    location => 'c:\\packages',
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
    assert_match(/c:\\packages/, get_xml_value("//sources/source[@id='test']/@value", result.output).to_s, 'Location did not match')
    assert_match(/false/, get_xml_value("//sources/source[@id='test']/@disabled", result.output).to_s, 'Disabled did not match')
  end
end
