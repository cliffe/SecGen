class misconfig_uid::change_uid ($file_input = [], $user = 'root', $facter_used = 'false') {

  user { 'user':
    ensure => 'present',
    home => '/home/user',
  }

  info("Factor input selected: $facter_used")

  # If facter not used ($facter_used = false)
  if !$facter_used {
    $file_input.each |$file, $permission_code| {
      notice("File to change to permission code $permission_code is: $file")
      file { $file:
      mode => $permission_code,
      owner => $user,
      }
    }
  }

# If facter is used ($facter_used = true)
  elsif $facter_used == 'true' {
    $file_input.each |$index, $value| {
    if (($index % 2) == 0) {
      # Value is odd
      $file = regsubst($file_input[$index],'"|\'','\1','G')
      $permission_code = regsubst($file_input[$index + 1],'"|\'','\1','G')

      file { $file:
        mode => $permission_code,
        owner => $user,
      }
    } else {
      # Value is even so do nothing
    }
    }
  }
}