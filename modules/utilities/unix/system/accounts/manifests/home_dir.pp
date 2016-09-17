#
# Specified how home directories are managed.
#
# [*name*] Name of the home directory that is being managed.
# [*user*] User that owns all of the files being created.
# [*sshkeys*] List of ssh keys to be added for this user in this
# directory
define accounts::home_dir(
  $user,
  $bashrc_content       = undef,
  $bash_profile_content = undef,
  $mode                 = '0700',
  $ensure               = 'present',
  $managehome           = true,
  $sshkeys              = [],
) {
  validate_re($ensure, '^(present|absent)$')

  if $ensure == 'absent' and $managehome == true {
    file { $name:
      ensure  => absent,
      recurse => true,
      force   => true,
    }
  } elsif $ensure == 'present' and $managehome == true {

    $key_file = "${name}/.ssh/authorized_keys"

    # Solaris homedirs are managed in zfs by `useradd -m`. If the directory
    # does not yet exist then we can't predict how it should be created, but we
    # should still manage the user/group/mode
    file { $name:
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => $mode,
    }

    file { "${name}/.ssh":
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0700',
    }

    file { "${name}/.vim":
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0700',
    }

    if $bashrc_content {
      file { "${name}/.bashrc":
        ensure  => file,
        content => $bashrc_content,
        owner   => $user,
        group   => $user,
        mode    => '0644',
      }
    }
    if $bash_profile_content {
      file { "${name}/.bash_profile":
        ensure  => file,
        content => $bash_profile_content,
        owner   => $user,
        group   => $user,
        mode    => '0644',
      }
    }

    file { $key_file:
      ensure => file,
      owner  => $user,
      group  => $user,
      mode   => '0600',
    }

    if $sshkeys != [] {
      accounts::manage_keys { $sshkeys:
        user     => $user,
        key_file => $key_file,
        require  => File["${name}/.ssh"],
        before   => File[$key_file],
      }
    }
  } elsif $managehome == false {
    if $sshkeys != [] {
      warning("ssh keys were passed for user ${user} but \$managehome is set to false; not managing user ssh keys")
    }
  }
}
