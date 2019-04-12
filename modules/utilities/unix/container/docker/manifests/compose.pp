# == Class: docker::compose
#
# Class to install Docker Compose using the recommended curl command.
#
# === Parameters
#
# [*ensure*]
#   Whether to install or remove Docker Compose
#   Valid values are absent present
#   Defaults to present
#
# [*version*]
#   The version of Docker Compose to install.
#   Defaults to the value set in $docker::params::compose_version
#
# [*install_path*]
#   The path where to install Docker Compose.
#   Defaults to the value set in $docker::params::compose_install_path
#
# [*proxy*]
#   Proxy to use for downloading Docker Compose.
#
class docker::compose(
  Optional[Pattern[/^present$|^absent$/]] $ensure          = 'present',
  Optional[String] $version                                = $docker::params::compose_version,
  Optional[String] $install_path                           = $docker::params::compose_install_path,
  Optional[String] $proxy                                  = undef
) inherits docker::params {

  if $proxy != undef {
      validate_re($proxy, '^((http[s]?)?:\/\/)?([^:^@]+:[^:^@]+@|)([\da-z\.-]+)\.([\da-z\.]{2,6})(:[\d])?([\/\w \.-]*)*\/?$')
  }

  if $::osfamily == 'windows' {
    $file_extension = '.exe'
    $file_owner = 'Administrator'
  } else {
    $file_extension = ''
    $file_owner = 'root'
  }

  $docker_compose_location = "${install_path}/docker-compose${file_extension}"
  $docker_compose_location_versioned = "${install_path}/docker-compose-${version}${file_extension}"

  if $ensure == 'present' {
    $docker_compose_url = "https://github.com/docker/compose/releases/download/${version}/docker-compose-${::kernel}-x86_64${file_extension}"

    if $proxy != undef {
      $proxy_opt = "--proxy ${proxy}"
      } else {
      $proxy_opt = ''
    }

    if $::osfamily == 'windows' {
      $docker_download_command = "if (Invoke-WebRequest ${docker_compose_url} ${proxy_opt} -UseBasicParsing -OutFile \"${docker_compose_location_versioned}\") { exit 0 } else { exit 1}"

      exec { 'Enable TLS 1.2 in powershell':
        path     => ['c:/Windows/Temp/', 'C:/Program Files/Docker/'],
        command  => '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12',
        provider => powershell,
        creates  => $docker_compose_location_versioned,
      }

      $script_path = 'C:/Windows/Temp/download_docker_compose.ps1'
      file{ $script_path:
        ensure  => present,
        force   => true,
        content => template('docker/windows/download_docker_compose.ps1.erb'),
        notify  => Exec["Install Docker Compose ${version}"],
      }

      exec { "Install Docker Compose ${version}":
        path     => ['c:/Windows/Temp/', 'C:/Program Files/Docker/'],
        command  => "& ${script_path}",
        provider => powershell,
        creates  => $docker_compose_location_versioned,
      }
    } else {
      ensure_packages(['curl'])
      exec { "Install Docker Compose ${version}":
        path    => '/usr/bin/',
        cwd     => '/tmp',
        command => "curl -s -S -L ${proxy_opt} ${docker_compose_url} -o ${docker_compose_location_versioned}",
        creates => $docker_compose_location_versioned,
        require => Package['curl'],
      }
    }

    file { $docker_compose_location_versioned:
      owner   => $file_owner,
      mode    => '0755',
      require => Exec["Install Docker Compose ${version}"]
    }

    file { $docker_compose_location:
      ensure  => 'link',
      target  => $docker_compose_location_versioned,
      require => File[$docker_compose_location_versioned]
    }
  } else {
    file { [
      $docker_compose_location_versioned,
      $docker_compose_location
    ]:
      ensure => absent,
    }
  }
}
