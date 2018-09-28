require 'chocolatey_helper'
test_name 'MODULES-3035 - Add a Value to an Existing Config Setting'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateyconfig {'proxy':
    ensure => present,
    value  => 'https://somewhere',
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
    assert_match(/https\:\/\/somewhere/, get_xml_value("//config/add[@key='proxy']/@value", result.output).to_s, 'Value did not match')
  end
end
