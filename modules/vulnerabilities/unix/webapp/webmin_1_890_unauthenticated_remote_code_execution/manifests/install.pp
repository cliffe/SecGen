#
class webmin_1_890_unauthenticated_remote_code_execution::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = 'webminusr'
  $install_dir = '/usr/local/webmin'
  $temp_dir = '/opt/Webmin_1.890'

  # Install the dependency perl.
  package { 'perl':
    ensure => installed,
    notify => Package['libnet-ssleay-perl'],
  }
  package { 'libnet-ssleay-perl':
    ensure  => installed,
    require => Package['perl'],
    notify  => Package['openssl'],
  }
  # Install the dependency openssl.
  package { 'openssl':
    ensure  => installed,
    require => Package['libnet-ssleay-perl'],
    notify  => Package['libauthen-pam-perl'],
  }
  # Install the dependency libauthen-pam-perl.
  package { 'libauthen-pam-perl':
    ensure  => installed,
    require => Package['openssl'],
    notify  => Package['libpam-runtime'],
  }
  # Install the dependency libpam-runtime.
  package { 'libpam-runtime':
    ensure  => installed,
    require => Package['libauthen-pam-perl'],
    notify  => Package['libio-pty-perl'],
  }
  # Install the dependency libio-pty-perl.
  package { 'libio-pty-perl':
    ensure  => installed,
    require => Package['libpam-runtime'],
    notify  => Package['apt-show-versions'],
  }
  # Install the dependency apt-show-versions.
  package { 'apt-show-versions':
    ensure  => installed,
    require => Package['libio-pty-perl'],
    notify  => Package['python'],
  }
  # Install the dependency python.
  package { 'python':
    ensure  => installed,
    require => Package['apt-show-versions'],
    notify  => Package['unzip'],
  }
  # Install the dependency unzip.
  package { 'unzip':
    ensure  => installed,
    require => Package['python'],
    notify  => User[$user],
  }

  # Create the directory /opt/Webmin_1.890/
  file { $temp_dir:
    ensure  => 'directory',
    owner   => $user,
    mode    => '0755',
    require => User[$user],
    notify  => File["${temp_dir}/webmin-1.890.tar.gz"],
  }

  # Copy the tar ball containing the Webmin installation files to /opt/Webmin_1.890/
  file { "${temp_dir}/webmin-1.890.tar.gz":
    owner   => $user,
    mode    => '0755',
    source  => 'puppet:///modules/webmin_1_890_unauthenticated_remote_code_execution/webmin-1.890.tar.gz',
    require => File[$temp_dir],
    notify  => Exec['mellow-file'],
  }

  # Extract the tar ball.
  exec { 'mellow-file':
    command => 'sudo tar -zvxf webmin-1.890.tar.gz',
    cwd     => $temp_dir,
    creates => "${temp_dir}/webmin-1.890/",
    require => File["${temp_dir}/webmin-1.890.tar.gz"],
    notify  => Exec['remove-default-setup'],
  }

  # This Exec function removes the default setup.sh file for Webmin.
  exec { 'remove-default-setup':
    command => 'sudo rm setup.sh',
    cwd     => "${temp_dir}/webmin-1.890/",
    require => Exec['mellow-file'],
    notify  => Exec["${temp_dir}/webmin-1.890/setup.sh"],
  }

  # '/opt/Webmin_1.890/webmin-1.890/setup.sh'.
  exec { "${temp_dir}/webmin-1.890/setup.sh":
    owner   => $user,
    mode    => '0755',
    source  => 'puppet:///modules/webmin_1_890_unauthenticated_remote_code_execution/setup.sh',
    require => File['remove-default-setup'],
    notify  => Exec['setup'],
  }

  # Run setup
  exec { 'setup':
    command => "sudo ./setup.sh ${install_dir}",
    cwd     => "${temp_dir}/webmin-1.890/",
    require => Exec["${temp_dir}/webmin-1.890/setup.sh"],
    notify  => Cron['start-webmin-cron'],
  }
  # Control now passes to the config.pp file.
}
