require 'chocolatey_helper'
test_name 'MODULES-3037 - Add Source Sad Path: Fail to apply bad manifest'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateysource {'test':
    ensure   => sad,
    location => 'c:\\packages',
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
  assert_match(/Error: Parameter ensure failed on Chocolateysource\[test\]: Invalid value "sad"/, stderr, "stderr did not match expected")
end
