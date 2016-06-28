class misconfig_information_leakage::change_information_leakage_permissions ($files_to_change_permissions = [], $facter_used = false) {
  notice("Factor input selected: $facter_used")
  info("Factor input selected: $facter_used")

  # If facter not used ($facter_used = false)
  if $facter_used == 'false' or $facter_used == false  {
    $files_to_change_permissions.each |$file, $permission_code| {
    notice("File to change to permission code $permission_code is: $file")
    file { $file:
        # ensure => 'file',
      mode => "$permission_code",
      }
    }
  }

# If facter is used ($facter_used = true)
  elsif $facter_used == 'true' or $facter_used == true {
    $files_to_change_permissions.each |$index, $value| {
      if (($index % 2) == 0) {
        # Value is odd
        $file = regsubst($files_to_change_permissions[$index],'"|\'','\1','G')
        $permission_code = regsubst($files_to_change_permissions[$index + 1],'"|\'','\1','G')

        notice("file is: $file")
        notice("permission_code is: $permission_code")
        file { $file:
          # ensure => 'file',
          mode => "$permission_code",
        }
      } else {
        # Value is even so do nothing
      }
    }
  }

  else { err("Incorrect value for facter_used {$facter_used} only accepted values are, true or false")}
}