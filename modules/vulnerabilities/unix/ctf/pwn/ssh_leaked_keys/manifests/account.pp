define ssh_leaked_keys::account ($username, $password, $strings_to_leak, $leaked_filenames, $ssh_key_pair ) {
  $ssh_private_key = $ssh_key_pair['private']
  $ssh_public_key = $ssh_key_pair['public']
  $public_key_string = "$ssh_public_key $username@domain"

  ::accounts::user { $username:
    shell      => '/bin/bash',
    password   => pw_hash($password, 'SHA-512', 'mysalt'),
    managehome => true,
    home_mode  => '0755',
    sshkeys    => [ $public_key_string ],
  }

  # Leak strings in a text file in the users home directory
  ::secgen_functions::leak_files { "$username-file-leak":
    storage_directory => "/home/$username/",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $username,
    group             => $username,
    mode              => '0600',
    leaked_from       => "accounts_$username",
  }

  # Move public key to box
  file { "/home/$username/.ssh/id_rsa.pub":
    owner   => $username,
    group   => $username,
    mode    => '0600',
    ensure  => file,
    content => $public_key_string,
    notify  => File["/home/$username/.ssh/id_rsa"],
  }

  # Move private key to box
  file { "/home/$username/.ssh/id_rsa":
    owner   => $username,
    group   => $username,
    mode    => '0600',
    ensure  => file,
    content => $ssh_private_key,
    notify  => Exec['pack_to_tar'],
  }

  # Pack the ssh keys to .tar.gz
  exec { 'pack_to_tar':
    cwd     => "/home/$username/.ssh/",
    command => "tar -cvzf /home/$username/.ssh.tar.gz *",
    path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
    notify  => Exec['setperm'],
  }

  exec { 'setperm':
    cwd     => "/home/$username/",
    command => "sudo chown -R $username:$username /home/$username/.ssh",
    path    => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
  }
}