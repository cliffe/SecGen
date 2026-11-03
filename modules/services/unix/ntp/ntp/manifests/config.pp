# @summary
#   This class handles the configuration file.
#
# @api private
#
class ntp::config {
  #The servers-netconfig file overrides NTP config on SLES 12, interfering with our configuration.
  if ($facts['os']['name'] == 'SLES' and $facts['os']['release']['major'] == '12') or
  ($facts['os']['name'] == 'OpenSuSE' and $facts['os']['release']['major'] == '42') {
    file { '/var/run/ntp/servers-netconfig':
      ensure => 'absent',
    }
  }

  case $facts['os']['family'] {
    'redhat': {
      $daemon_config = '/etc/sysconfig/ntpd'
      if $ntp::daemon_extra_opts {
        file_line { 'Set NTPD daemon options':
          ensure => present,
          path   => $daemon_config,
          line   => "OPTIONS='${ntp::daemon_extra_opts}'",
          match  => '^OPTIONS\=',
        }
      }
      if $ntp::user and $facts['os']['release']['major'] != '6' {
        file_line { 'Set NTPD daemon user':
          ensure => present,
          path   => '/etc/systemd/system/multi-user.target.wants/ntpd.service',
          line   => "ExecStart=/usr/sbin/ntpd -u ${ntp::user}:${ntp::user} \$OPTIONS",
          match  => '^ExecStart\=',
        }
      }
    }
    'Debian': {
      $daemon_config = '/etc/default/ntp'
      if $ntp::daemon_extra_opts {
        file_line { 'Set NTPD daemon options':
          ensure => present,
          path   => $daemon_config,
          line   => "NTPD_OPTS='${ntp::daemon_extra_opts}'",
          match  => '^NTPD_OPTS\=',
        }
      }
      if $ntp::user and $facts['os']['release']['major'] == '18.04' {
        file_line { 'Set NTPD daemon user':
          ensure => present,
          path   => '/usr/lib/ntp/ntp-systemd-wrapper',
          line   => "RUNASUSER=${ntp::user}",
          match  => '^RUNASUSER\=',
        }
      }
    }
    'Suse': {
      $daemon_config = '/etc/sysconfig/ntp'
      if $ntp::daemon_extra_opts {
        file_line { 'Set NTPD daemon options':
          ensure => present,
          path   => $daemon_config,
          line   => "OPTIONS='${ntp::daemon_extra_opts}'",
          match  => '^OPTIONS\=',
        }
      }
    }
    default: {
      # Empty
    }
  }

  if $ntp::keys_enable {
    case $ntp::config_dir {
      '/', '/etc', undef: {}
      default: {
        file { $ntp::config_dir:
          ensure  => directory,
          owner   => 0,
          group   => 0,
          mode    => '0775',
          recurse => false,
        }
      }
    }

    file { $ntp::keys_file:
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0600',
      content => epp('ntp/keys.epp'),
    }
  }

  #If both epp and erb are defined, throw validation error.
  #Otherwise use the defined erb/epp template, or use default
  if $ntp::config_epp and $ntp::config_template {
    fail('Cannot supply both config_epp and config_template templates for ntp config file.')
  } elsif $ntp::config_template {
    $config_content = template($ntp::config_template)
  } elsif $ntp::config_epp {
    $config_content = epp($ntp::config_epp)
  } else {
    $config_content = epp('ntp/ntp.conf.epp')
  }

  file { $ntp::config:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => $ntp::config_file_mode,
    content => $config_content,
  }

  #If both epp and erb are defined, throw validation error.
  #Otherwise use the defined erb/epp template, or use default

  if $ntp::step_tickers_file {
    if $ntp::step_tickers_template and $ntp::step_tickers_epp {
      fail('Cannot supply both step_tickers_file and step_tickers_epp templates for step ticker file')
    } elsif $ntp::step_tickers_template {
      $step_ticker_content = template($ntp::step_tickers_template)
    } elsif $ntp::step_tickers_epp {
      $step_ticker_content = epp($ntp::step_tickers_epp)
    } else {
      $step_ticker_content = epp('ntp/step-tickers.epp')
    }

    file { $ntp::step_tickers_file:
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => $ntp::config_file_mode,
      content => $step_ticker_content,
    }
  }

  if $ntp::logfile {
    file { $ntp::logfile:
      ensure => file,
      owner  => $ntp::logfile_user,
      group  => $ntp::logfile_group,
      mode   => $ntp::logfile_mode,
    }
  }

  if $ntp::disable_dhclient {
    augeas { 'disable ntp-servers in dhclient.conf':
      context => '/files/etc/dhcp/dhclient.conf',
      changes => 'rm request/*[.="ntp-servers"]',
    }

    file { '/var/lib/ntp/ntp.conf.dhcp':
      ensure => absent,
    }

    #remove dhclient ntp script which modifies ntp.conf on RHEL and Amazon Linux
    file { '/etc/dhcp/dhclient.d/ntp.sh':
      ensure => absent,
    }
  }
}
