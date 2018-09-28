require 'chocolatey_helper'
test_name 'MODULES-3430 - Add Source Sad Path: Fail to apply manifest without location'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateysource {'chocolatey':
    ensure   => present,
  }
PP

# teardown
teardown do
  reset_config
end

# act
step 'Apply manifest'
apply_manifest(chocolatey_src, :expect_failures => true) do
  step 'Verify failure'
  assert_match(/Error: Validation of Chocolateysource\[chocolatey\] failed: A non-empty location/, stderr, "stderr did not match expected")
end
