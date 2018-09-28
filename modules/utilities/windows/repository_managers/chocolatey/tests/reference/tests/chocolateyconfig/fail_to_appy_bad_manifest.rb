require 'chocolatey_helper'
test_name 'MODULES-3035 - Fail to Apply Bad Manifest'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateyconfig {'bob':
    ensure => sad,
    value  => 'yes',
  }
PP

# teardown
teardown do
  reset_config
end

# act
step 'Apply Manifest'
apply_manifest(chocolatey_src, :expect_failures => true) do
  step 'Verify Failure'
  assert_match(/Error: Parameter ensure failed on Chocolateyconfig\[bob\]: Invalid value "sad"/, stderr, "stderr did not match expected")
end
