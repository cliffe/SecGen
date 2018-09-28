require 'chocolatey_helper'
test_name 'MODULES-3035 - Config Settings Change Config Value'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateyconfig {'proxyUser':
    value => 'bob',
  }
PP

# teardown
teardown do
  reset_config
end

# act
step 'Apply manifest to setup'
apply_manifest(chocolatey_src, :catch_failures => true)

step 'Verify setup'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/bob/, get_xml_value("//config/add[@key='proxyUser']/@value", result.output).to_s, 'Value did not match')
  end
end

# arrange
chocolatey_src_change = <<-PP
  chocolateyconfig {'proxyuser':
    value => 'tim',
  }
PP

# act
step 'Apply manifest to change config setting'
apply_manifest(chocolatey_src_change, :catch_failures => true)

step 'Verify results'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_match(/tim/, get_xml_value("//config/add[@key='proxyUser']/@value", result.output).to_s, 'Value did not change')
  end
end
