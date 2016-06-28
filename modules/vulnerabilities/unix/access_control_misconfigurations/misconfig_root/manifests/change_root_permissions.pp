class misconfig_root::change_root_permissions ($files_to_change_permissions = [], $facter_used = false) {
  info("Factor input selected: $facter_used")

  # If facter not used ($facter_used = false)
  if !$facter_used {
    $files_to_change_permissions.each |$file, $permission_code| {
    notice("File to change to permission code $permission_code is: $file")
    file { $file:
      # ensure => 'file',
      mode => "$permission_code",
    }
  }
}

  # If facter is used ($facter_used = true)
  elsif $facter_used == 'true' {
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
}