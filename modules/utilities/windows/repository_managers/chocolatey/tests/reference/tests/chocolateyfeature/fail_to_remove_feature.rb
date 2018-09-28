require 'chocolatey_helper'
test_name 'MODULES-3034 - Attempt to remove feature'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateyfeature {'checksumFiles':
    ensure => absent,
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
  assert_match(/Error: Parameter ensure failed on Chocolateyfeature\[checksumFiles\]: Invalid value \"absent\"/, stderr, "stderr did not match expected")
end

