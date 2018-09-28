require 'chocolatey_helper'
test_name 'MODULES-3035 - Config Settings Remove Value with Password in Name'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateyconfig {'proxypassword':
    value => 'secrect',
  }
PP

# teardown
teardown do
  reset_config
end

password = ''

# act
step 'Apply manifest to setup proxyPassword'
apply_manifest(chocolatey_src, :catch_failures => true)

step 'Verify setup'
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    password = get_xml_value("//config/add[@key='proxyPassword']/@value", result.output).to_s
    assert_match(/.+/, password, 'Value did not match')
  end
end

# arrange
chocolatey_src_change = <<-PP
  chocolateyconfig {'proxypassword':
    ensure => absent,
  }
PP

# act
step 'Apply manifest to remove proxyPassword'
apply_manifest(chocolatey_src_change, :catch_failures => true)

step 'Verify results'
# should have no effect
agents.each do |agent|
  on(agent, "cmd.exe /c \"type #{config_file_location}\"") do |result|
    assert_not_match(/.+/, get_xml_value("//config/add[@key='proxyPassword']/@value", result.output).to_s, 'Value should have been removed')
  end
end
