class wifi_mouse_linux::install {
  Exec {
    path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin']
  }

  exec {'apt-update':
    command => 'apt update',
  } ->
  exec {'install-requirements':
    command => 'apt install -y build-essential cmake libavahi-client-dev libgtk-3-dev libglade2-dev',
  } ->
  file {'/root/mouseserver-sourcecode-Linux.zip':
    source => 'puppet:///modules/wifi_mouse_linux/mouseserver-sourcecode-Linux.zip',
  } ->
  exec {'extract-remote-mouse-source':
    command => 'unzip /root/mouseserver-sourcecode-Linux.zip; rm mouseserver-sourcecode-Linux.zip',
    cwd => '/root',
    creates => '/root/mouseserver-sourcecode-Linux',
  } ->
  exec {'configure-remote-mouse-build':
    command => 'bash -c "export CFLAGS=$(pkg-config --cflags --libs gtk+-3.0 pango); export CXXFLAGS=$(pkg-config --cflags --libs gtk+-3.0 pango); cmake ."',
    cwd => '/root/mouseserver-sourcecode-Linux',
  } ->
  exec {'build-remote-mouse-build':
    command => 'make',
    cwd => '/root/mouseserver-sourcecode-Linux',
  } ->
  exec {'install-remote-mouse-build':
    command => 'make install',
    cwd => '/root/mouseserver-sourcecode-Linux',
  } ->
  file { '/etc/systemd/system/wifi_mouse.service':
    source => 'puppet:///modules/wifi_mouse_linux/wifi_mouse.service'
  } ->
  exec {'enable-wifi-mouse-service':
    command => 'systemctl enable --now wifi_mouse'
  }

  $leaked_filenames = ["wifi_mouse_linux_flag.txt"]
  $strings_to_leak = ["that's one insecure remote"]

  ::secgen_functions::leak_files { 'wifi_mouse_linux':
    storage_directory => "/root",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    leaked_from       => 'wifi_mouse_linux',
  }
}
