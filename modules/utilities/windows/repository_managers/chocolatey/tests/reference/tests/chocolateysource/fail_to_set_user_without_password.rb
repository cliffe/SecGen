require 'chocolatey_helper'
test_name 'MODULES-3037 - Add Source Sad Path: Set user with no password'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateysource {'chocolatey':
    ensure   => present,
    location => 'https://chocolatey.org/api/v2',
    user => 'tim',
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
  assert_match(/Error: Validation of Chocolateysource\[chocolatey\] failed: If specifying user\/password, you must specify both values/, stderr, "stderr did not match expected")
end
