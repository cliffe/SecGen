require 'chocolatey_helper'
test_name 'MODULES-3035 - Fail to Set Present With No Value'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateyconfig {'bob':
    ensure => present,
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
  assert_match(/Error: Validation of Chocolateyconfig\[bob\] failed: Unless ensure => absent, value is required/, stderr, "stderr did not match expected")
end
