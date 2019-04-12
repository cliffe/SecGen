# == Define: python::virtualenv
#
# Creates Python virtualenv.
#
# === Parameters
#
# [*ensure*]
#  present|absent. Default: present
#
# [*version*]
#  Python version to use. Default: system default
#
# [*requirements*]
#  Path to pip requirements.txt file. Default: none
#
# [*systempkgs*]
#  Copy system site-packages into virtualenv. Default: don't
#  If virtualenv version < 1.7 this flag has no effect since
# [*venv_dir*]
#  Directory to install virtualenv to. Default: $name
#
# [*distribute*]
#  Include distribute in the virtualenv. Default: true
#
# [*index*]
#  Base URL of Python package index. Default: none (http://pypi.python.org/simple/)
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
# [*proxy*]
#  Proxy server to use for outbound connections. Default: none
#
# [*environment*]
#  Additional environment variables required to install the packages. Default: none
#
# [*path*]
#  Specifies the PATH variable. Default: [ '/bin', '/usr/bin', '/usr/sbin' ]
#
# [*cwd*]
#  The directory from which to run the "pip install" command. Default: undef
#
# [*timeout*]
#  The maximum time in seconds the "pip install" command should take. Default: 1800
#
# [*pip_args*]
#  Arguments to pass to pip during initialization.  Default: blank
#
# [*extra_pip_args*]
#  Extra arguments to pass to pip after requirements file.  Default: blank
#
# === Examples
#
# python::virtualenv { '/var/www/project1':
#   ensure       => present,
#   version      => 'system',
#   requirements => '/var/www/project1/requirements.txt',
#   proxy        => 'http://proxy.domain.com:3128',
#   systempkgs   => true,
#   index        => 'http://www.example.com/simple/',
# }
#
# === Authors
#
# Sergey Stankevich
# Shiva Poudel
#
define python::virtualenv (
  $ensure           = present,
  $version          = 'system',
  $requirements     = false,
  $systempkgs       = false,
  $venv_dir         = $name,
  $distribute       = true,
  $index            = false,
  $owner            = 'root',
  $group            = 'root',
  $mode             = '0755',
  $proxy            = false,
  $environment      = [],
  $path             = [ '/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
  $cwd              = undef,
  $timeout          = 1800,
  $pip_args         = '',
  $extra_pip_args   = '',
  $virtualenv       = undef
) {
  include ::python

  if $ensure == 'present' {
    $python = $version ? {
      'system' => 'python',
      'pypy'   => 'pypy',
      default  => "python${version}",
    }

    if $virtualenv == undef {
      $used_virtualenv = 'virtualenv'
    } else {
      $used_virtualenv = $virtualenv
    }

    $proxy_flag = $proxy ? {
      false    => '',
      default  => "--proxy=${proxy}",
    }

    $proxy_command = $proxy ? {
      false   => '',
      default => "&& export http_proxy=${proxy}",
    }

    # Virtualenv versions prior to 1.7 do not support the
    # --system-site-packages flag, default off for prior versions
    # Prior to version 1.7 the default was equal to --system-site-packages
    # and the flag --no-site-packages had to be passed to do the opposite
    $_virtualenv_version = getvar('virtualenv_version') ? {
      /.*/ => getvar('virtualenv_version'),
      default => '',
    }
    if (( versioncmp($_virtualenv_version,'1.7') > 0 ) and ( $systempkgs == true )) {
      $system_pkgs_flag = '--system-site-packages'
    } elsif (( versioncmp($_virtualenv_version,'1.7') < 0 ) and ( $systempkgs == false )) {
      $system_pkgs_flag = '--no-site-packages'
    } else {
      $system_pkgs_flag = $systempkgs ? {
        true    => '--system-site-packages',
        false   => '--no-site-packages',
        default => fail('Invalid value for systempkgs. Boolean value is expected')
      }
    }

    $distribute_pkg = $distribute ? {
      true     => 'distribute',
      default  => 'setuptools',
    }
    $pypi_index = $index ? {
      false   => '',
      default => "-i ${index}",
    }

    # Python 2.6 and older does not support setuptools/distribute > 0.8 which
    # is required for pip wheel support, pip therefor requires --no-use-wheel flag
    # if the # pip version is more recent than 1.4.1 but using an old python or
    # setuputils/distribute version
    # To check for this we test for wheel parameter using help and then using
    # version, this makes sure we only use wheels if they are supported

    file { $venv_dir:
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode
    }

    $virtualenv_cmd = "${python::exec_prefix}${used_virtualenv}"

    $pip_cmd   = "${python::exec_prefix}${venv_dir}/bin/pip"
    $pip_flags = "${pypi_index} ${proxy_flag} ${pip_args}"

    exec { "python_virtualenv_${venv_dir}":
      command     => "true ${proxy_command} && ${virtualenv_cmd} ${system_pkgs_flag} -p ${python} ${venv_dir} && ${pip_cmd} --log ${venv_dir}/pip.log install ${pip_flags} --upgrade pip && ${pip_cmd} install ${pip_flags} --upgrade ${distribute_pkg}",
      user        => $owner,
      creates     => "${venv_dir}/bin/activate",
      path        => $path,
      cwd         => '/tmp',
      environment => $environment,
      unless      => "grep '^[\\t ]*VIRTUAL_ENV=[\\\\'\\\"]*${venv_dir}[\\\"\\\\'][\\t ]*$' ${venv_dir}/bin/activate", #Unless activate exists and VIRTUAL_ENV is correct we re-create the virtualenv
      require     => File[$venv_dir],
    }

    if $requirements {
      exec { "python_requirements_initial_install_${requirements}_${venv_dir}":
        command     => "${pip_cmd} --log ${venv_dir}/pip.log install ${pypi_index} ${proxy_flag} --no-binary :all: -r ${requirements} ${extra_pip_args}",
        refreshonly => true,
        timeout     => $timeout,
        user        => $owner,
        subscribe   => Exec["python_virtualenv_${venv_dir}"],
        environment => $environment,
        cwd         => $cwd
      }

      python::requirements { "${requirements}_${venv_dir}":
        requirements   => $requirements,
        virtualenv     => $venv_dir,
        proxy          => $proxy,
        owner          => $owner,
        group          => $group,
        cwd            => $cwd,
        require        => Exec["python_virtualenv_${venv_dir}"],
        extra_pip_args => $extra_pip_args,
      }
    }
  } elsif $ensure == 'absent' {
    file { $venv_dir:
      ensure  => absent,
      force   => true,
      recurse => true,
      purge   => true,
    }
  }
}
