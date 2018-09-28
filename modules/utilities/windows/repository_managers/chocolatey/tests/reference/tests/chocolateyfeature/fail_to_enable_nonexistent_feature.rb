require 'chocolatey_helper'
test_name 'MODULES-3034 - Enable non-existent feature'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateyfeature {'idontexistfeature123123':
    ensure => enabled,
  }
PP

# teardown
teardown do
  reset_config
end

# act
step 'Apply manifest'
apply_manifest(chocolatey_src, :expect_failures => true) do
  step 'Verify Failure'
  assert_match(/returned 1: Feature 'idontexistfeature123123' not found/, stderr, "stderr did not match expected")
end
