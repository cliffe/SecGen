# == Define: python::pyvenv
#
# Create a Python3 virtualenv using pyvenv.
#
# === Parameters
#
# [*ensure*]
#  present|absent. Default: present
#
# [*version*]
#  Python version to use. Default: system default
#
# [*systempkgs*]
#  Copy system site-packages into virtualenv. Default: don't
#
# [*venv_dir*]
#  Directory to install virtualenv to. Default: $name
#
# [*owner*]
#  The owner of the virtualenv being manipulated. Default: root
#
# [*group*]
#  The group relating to the virtualenv being manipulated. Default: root
#
# [*mode*]
# Optionally specify directory mode. Default: 0755
#
# [*path*]
#  Specifies the PATH variable. Default: [ '/bin', '/usr/bin', '/usr/sbin' ]

# [*environment*]
# Optionally specify environment variables for pyvenv
#
# === Examples
#
# python::venv { '/var/www/project1':
#   ensure       => present,
#   version      => 'system',
#   systempkgs   => true,
# }
#
# === Authors
#
# Sergey Stankevich
# Ashley Penney
# Marc Fournier
# Fotis Gimian
# Seth Cleveland
#
define python::pyvenv (
  $ensure           = present,
  $version          = 'system',
  $systempkgs       = false,
  $venv_dir         = $name,
  $owner            = 'root',
  $group            = 'root',
  $mode             = '0755',
  $path             = [ '/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
  $environment      = [],
) {

  include ::python

  if $ensure == 'present' {

    $virtualenv_cmd = $version ? {
      'system' => "${python::exec_prefix}pyvenv",
      default  => "${python::exec_prefix}pyvenv-${version}",
    }

    if ( $systempkgs == true ) {
      $system_pkgs_flag = '--system-site-packages'
    } else {
      $system_pkgs_flag = ''
    }

    file { $venv_dir:
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode
    }

    exec { "python_virtualenv_${venv_dir}":
      command     => "${virtualenv_cmd} --clear ${system_pkgs_flag} ${venv_dir}",
      user        => $owner,
      creates     => "${venv_dir}/bin/activate",
      path        => $path,
      cwd         => '/tmp',
      environment => $environment,
      unless      => "grep '^[\\t ]*VIRTUAL_ENV=[\\\\'\\\"]*${venv_dir}[\\\"\\\\'][\\t ]*$' ${venv_dir}/bin/activate", #Unless activate exists and VIRTUAL_ENV is correct we re-create the virtualenv
      require     => File[$venv_dir],
    }
  } elsif $ensure == 'absent' {
    file { $venv_dir:
      ensure  => absent,
      force   => true,
      recurse => true,
      purge   => true,
    }
  } else {
    fail( "Illegal ensure value: ${ensure}. Expected (present or absent)")
  }
}
