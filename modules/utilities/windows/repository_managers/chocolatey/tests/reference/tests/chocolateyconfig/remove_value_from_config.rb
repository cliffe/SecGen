require 'chocolatey_helper'
test_name 'MODULES-3035 - Remove Value From Config Setting'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateyconfig {'commandExecutionTimeoutSeconds':
    ensure   => absent,
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
    assert_not_match(/.+/, get_xml_value("//config/add[@key='commandExecutionTimeoutSeconds']/@value", result.output).to_s, 'Value did not match')
  end
end
