class unrealirc::service {

  Exec {
    path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
  }

  if $::osfamily == 'Debian' {

      file { '/etc/init.d/unreal':
        ensure   => file,
        mode     => '0755',
        content  => template('unrealirc/unreal.erb'),
      }

      exec { 'unrealirc_autoload':
        command => 'update-rc.d unreal defaults',
        require => File['/etc/init.d/unreal'],
      }

      # make systemd generate the unit from the new init script
      exec { 'unrealirc_daemon_reload':
        command => 'systemctl daemon-reload',
        onlyif  => 'which systemctl',
        require => Exec['unrealirc_autoload'],
      }

      service { 'unreal':
        ensure      => running,
        enable      => true,
        hasrestart  => true,
        hasstatus   => true,
        require     => [File['/etc/init.d/unreal'], Exec['unrealirc_daemon_reload']],
        notify => Exec['initial_run'],
      }

      exec { 'initial_run':
        command => '/etc/init.d/unreal start'
      }
  }

}


