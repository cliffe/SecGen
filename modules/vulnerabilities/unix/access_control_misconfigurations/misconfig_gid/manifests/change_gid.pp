class misconfig_gid::change_gid ( $file_input = [], $group = 'test', $user = 'user', $facter_used = false) {

  group { 'test':
    # gid => 'test',
    name   => 'test',
    ensure => 'present',
  }

  user { 'user':
    # name => 'user',
    # gid => 'test',
    groups => 'test',
    ensure => 'present',
  }

  user { 'user_non_group':
    # name => 'user',
    # gid => 'test',
    # groups => 'test',
    ensure => 'present',
  }
  
  info("Factor input selected: $facter_used")

  # If facter not used ($facter_used = false)
  if !$facter_used {
    $file_input.each |$file, $group| {
      notice("File to change to permission code $group is: $file")
      file { $file:
        # ensure => 'file',
        mode => "$permission_code",
      }
    }
  }

  # If facter is used ($facter_used = true)
  elsif $facter_used == 'true' {
    $file_input.each |$index, $value| {
      if (($index % 2) == 0) {
        # Value is odd
        $file = regsubst($file_input[$index],'"|\'','\1','G')
        $group = regsubst($file_input[$index + 1],'"|\'','\1','G')

        file { $file:
          # ensure => 'file',
          # mode => "$permission_code",
          group => $group,
        }
      } else {
        # Value is even so do nothing
      }
    }
  }
}