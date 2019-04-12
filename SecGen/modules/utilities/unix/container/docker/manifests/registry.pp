# == Class: docker
#
# Module to configure private docker registries from which to pull Docker images
# If the registry does not require authentication, this module is not required.
#
# === Parameters
# [*server*]
#   The hostname and port of the private Docker registry. Ex: dockerreg:5000
#
# [*ensure*]
#   Whether or not you want to login or logout of a repository
#
# [*username*]
#   Username for authentication to private Docker registry.
#   auth is not required.
#
# [*password*]
#   Password for authentication to private Docker registry. Leave undef if
#   auth is not required.
#
# [*pass_hash*]
#   The hash to be used for receipt. If left as undef, a hash will be generated
#
# [*email*]
#   Email for registration to private Docker registry. Leave undef if
#   auth is not required.
#
# [*local_user*]
#   The local user to log in as. Docker will store credentials in this
#   users home directory
#
# [*receipt*]
#   Required to be true for idempotency
#
define docker::registry(
  Optional[String] $server                             = $title,
  Optional[Pattern[/^present$|^absent$/]] $ensure      = 'present',
  Optional[String] $username                           = undef,
  Optional[String] $password                           = undef,
  Optional[String] $pass_hash                          = undef,
  Optional[String] $email                              = undef,
  Optional[String] $local_user                         = 'root',
  Optional[String] $version                            = $docker::version,
  Optional[Boolean] $receipt                           = true,
) {
  include docker::params

  $docker_command = $docker::params::docker_command

  if $::osfamily == 'windows' {
    $exec_environment = ['PATH=C:/Program Files/Docker/']
    $exec_timeout = 3000
    $exec_path = ['c:/Windows/Temp/', 'C:/Program Files/Docker/']
    $exec_provider = 'powershell'
    $password_env = '$env:password'
    $exec_user = undef
  } else {
    $exec_environment = ['HOME=/root']
    $exec_path = ['/bin', '/usr/bin']
    $exec_timeout = 0
    $exec_provider = undef
    $password_env = "\${password}"
    $exec_user = $local_user
  }

  if $ensure == 'present' {
    if $username != undef and $password != undef and $email != undef and $version != undef and $version =~ /1[.][1-9]0?/ {
      $auth_cmd = "${docker_command} login -u '${username}' -p \"${password_env}\" -e '${email}' ${server}"
      $auth_environment = "password=${password}"
    }
    elsif $username != undef and $password != undef {
      $auth_cmd = "${docker_command} login -u '${username}' -p \"${password_env}\" ${server}"
      $auth_environment = "password=${password}"
    }
    else {
      $auth_cmd = "${docker_command} login ${server}"
      $auth_environment = ''
    }
  }
  else {
    $auth_cmd = "${docker_command} logout ${server}"
    $auth_environment = ''
  }

  $docker_auth = "${title}${auth_environment}${auth_cmd}${local_user}"

  if $auth_environment != '' {
    $exec_env = concat($exec_environment, $auth_environment, "docker_auth=${docker_auth}")
  } else {
    $exec_env = concat($exec_environment, "docker_auth=${docker_auth}")
  }

  if $receipt {

    if $::osfamily != 'windows' {
      # server may be an URI, which can contain /
      $server_strip = regsubst($server, '/', '_', 'G')

      # no - with pw_hash
      $local_user_strip = regsubst($local_user, '-', '', 'G')

      $_pass_hash = $pass_hash ? {
        Undef   => pw_hash($docker_auth, 'SHA-512', $local_user_strip),
        default => $pass_hash
      }
      $_auth_command = "${auth_cmd} || rm -f \"/root/registry-auth-puppet_receipt_${server_strip}_${local_user}\""

      file { "/root/registry-auth-puppet_receipt_${server_strip}_${local_user}":
        ensure  => $ensure,
        content => $_pass_hash,
        notify  => Exec["${title} auth"],
      }
    } else {
      # server may be an URI, which can contain /
      $server_strip = regsubst($server, '[/:]', '_', 'G')
      $passfile = "C:/Windows/Temp/registry-auth-puppet_receipt_${server_strip}_${local_user}"
      $_auth_command = "if (-not (${auth_cmd})) { Remove-Item -Path ${passfile} -Force -Recurse -EA SilentlyContinue; exit 0 } else { exit 0 }"

      if $ensure == 'absent' {
        file { $passfile:
          ensure => $ensure,
          notify => Exec["${title} auth"],
        }
      } elsif $ensure == 'present' {
        exec { 'compute-hash':
            command     => template('docker/windows/compute_hash.ps1.erb'),
            environment => $exec_env,
            provider    => $exec_provider,
            logoutput   => true,
            unless      => template('docker/windows/check_hash.ps1.erb'),
            notify      => Exec["${title} auth"],
        }
      }
    }
  }
  else {
    $_auth_command = $auth_cmd
  }

  exec { "${title} auth":
    environment => $exec_env,
    command     => $_auth_command,
    user        => $exec_user,
    path        => $exec_path,
    timeout     => $exec_timeout,
    provider    => $exec_provider,
    refreshonly => $receipt,
  }

}
