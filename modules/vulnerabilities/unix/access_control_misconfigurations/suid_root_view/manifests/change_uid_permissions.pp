class suid_root_view::change_uid_permissions ($file_input = [],$user = 'root') {
  $file_input.each |String $file, String $permission_code| {
    # /usr/bin/view and /etc/alternatives/view are symlinks to the real vim
    # binary. Without links => follow, Puppet manages the link itself and the
    # target stays 0755, so the setuid bit never lands.
    file { $file:
      links => follow,
      mode  => $permission_code,
      owner => $user,
    }
  notice("File {$file} permissions have been checked.")
  }
}
