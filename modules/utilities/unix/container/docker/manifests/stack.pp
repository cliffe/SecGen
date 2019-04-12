# == Define: docker::stack
#
# A define that deploys Docker stacks or compose v3
#
# == Paramaters
#
# [*ensure*]
#  This ensures that the stack is present or not.
#  Defaults to present
#
# [*stack_name*]
#   The name of the stack that you are deploying
#   Defaults to undef
#
# [*bundle_file*]
#  Path to a Distributed Application Bundle file
#  Please note this is experimental
#  Defaults to undef
#
# [*compose_file*]
#  Path to a Compose file
#  Defaults to undef
#
# [*prune*]
#  Prune services that are no longer referenced
#  Defaults to undef
#
# [*resolve_image*]
#  Query the registry to resolve image digest and supported platforms
#  Only accepts (“always”|“changed”|“never”)
#  Defaults to undef
#
# [*with_registry_auth*]
#  Send registry authentication details to Swarm agents
#  Defaults to undef

define docker::stack(

  Optional[Pattern[/^present$|^absent$/]] $ensure                = 'present',
  Optional[String] $stack_name                                   = undef,
  Optional[String] $bundle_file                                  = undef,
  Optional[Array] $compose_files                                 = undef,
  Optional[String] $prune                                        = undef,
  Optional[String] $with_registry_auth                           = undef,
  Optional[Pattern[/^always$|^changed$|^never$/]] $resolve_image = undef,
  ){

  include docker::params

  $docker_command = "${docker::params::docker_command} stack"

  if $::osfamily == 'windows' {
    $exec_path = ['C:/Program Files/Docker/']
    $check_stack = '$info = docker stack ls | select-string -pattern web
                    if ($info -eq $null) { Exit 1 } else { Exit 0 }'
    $provider = 'powershell'
  } else {
    $exec_path = ['/bin', '/usr/bin']
    $check_stack = "${docker_command} ls | grep ${stack_name}"
    $provider = undef
  }

  if $ensure == 'present'{
      $docker_stack_flags = docker_stack_flags ({
      stack_name => $stack_name,
      bundle_file => $bundle_file,
      compose_files => $compose_files,
      prune => $prune,
      with_registry_auth => $with_registry_auth,
      resolve_image => $resolve_image,
      })

      $exec_stack = "${docker_command} deploy ${docker_stack_flags} ${stack_name}"

      exec { "docker stack create ${stack_name}":
      command  => $exec_stack,
      unless   => $check_stack,
      path     => $exec_path,
      provider => $provider,
    }
  }

  if $ensure == 'absent'{

  exec { "docker stack destroy ${stack_name}":
    command  => "${docker_command} rm ${stack_name}",
    onlyif   => $check_stack,
    path     => $exec_path,
    provider => $provider,
    }
  }
}
