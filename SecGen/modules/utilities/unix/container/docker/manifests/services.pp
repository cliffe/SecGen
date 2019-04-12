# == Define: docker::services
#
# A define that managers a Docker services
#
# == Paramaters
#
# [*ensure*]
#  This ensures that the service is present or not.
#  Defaults to present
#
# [*image*]
#  The Docker image to spwan the service from.
#  Defualts to undef
#
# [*detach*]
#  Exit immediately instead of waiting for the service to converge (default true)
#  Defaults to true
#
# [*env*]
#  Set environment variables
#  Defaults to []
#
# [*label*]
#  Service labels.
#  This used as metdata to configure constraints etc.
#  Defaults to []
#
# [*publish*]
#  Publish a port as a node port.
#  Defaults to undef
#
# [*replicas*]
#  Number of tasks (containers per service)
#  defaults to undef
#
# [*tty*]
#  Allocate a pseudo-TTY
#  Defaults to false
#
# [*user*]
#  Username or UID (format: <name|uid>[:<group|gid>])
#  Defaults to undef
#
# [*workdir*]
#  Working directory inside the container
#  Defaults to false
#
# [*extra_params*]
#  Allows you to pass any other flag that the Docker service create supports.
#  This must be passed as an array. See docker service create --help for all options
#  defaults to []
#
# [*update*]
#  This changes the docker command to
#  docker service update, you must pass a service name with this option
#
# [*scale*]
#  This changes the docker command to
#  docker service scale, this can only be used with service name and
#  replicas
#
# [*host_socket*]
#  This will allow the service to connect to the host linux socket.
#  defaults to undef
#
# [*registry_mirror*]
#  This will allow the service to set a registry mirror.
#  defaults to undef
#
# [*command*]
#  Command to run on the container
#

define docker::services(
  Optional[Pattern[/^present$|^absent$/]] $ensure        = 'present',
  Optional[Boolean] $create                              = true,
  Optional[Boolean] $update                              = false,
  Optional[Boolean] $scale                               = false,
  Optional[Boolean] $detach                              = true,
  Optional[Boolean] $tty                                 = false,
  Optional[Array] $env                                   = [],
  Optional[Array] $label                                 = [],
  Optional[Array] $extra_params                          = [],
  Variant[String,Array,Undef] $image                     = undef,
  Variant[String,Array,Undef] $service_name              = undef,
  Variant[String,Array,Undef] $publish                   = undef,
  Variant[String,Array,Undef] $replicas                  = undef,
  Variant[String,Array,Undef] $user                      = undef,
  Variant[String,Array,Undef] $workdir                   = undef,
  Variant[String,Array,Undef] $host_socket               = undef,
  Variant[String,Array,Undef] $registry_mirror           = undef,
  Variant[String,Array,Undef] $command                   = undef,
){

  include docker::params

  $docker_command = "${docker::params::docker_command} service"

  if $ensure == 'absent' {
    if $update {
      fail translate(('When removing a service you can not update it.'))
    }
    if $scale {
      fail translate(('When removing a service you can not update it.'))
    }
  }

  if $::osfamily == 'windows' {
    $exec_environment = 'PATH=C:/Program Files/Docker/'
    $exec_timeout = 3000
    $exec_path = ['c:/Windows/Temp/', 'C:/Program Files/Docker/']
    $exec_provider = 'powershell'
  } else {
    $exec_environment = 'HOME=/root'
    $exec_path = ['/bin', '/usr/bin']
    $exec_timeout = 0
    $exec_provider = undef
  }


  if $create {
    $docker_service_create_flags = docker_service_flags({
      detach          => $detach,
      env             => any2array($env),
      service_name    => $service_name,
      label           => any2array($label),
      publish         => $publish,
      replicas        => $replicas,
      tty             => $tty,
      user            => $user,
      workdir         => $workdir,
      extra_params    => any2array($extra_params),
      image           => $image,
      host_socket     => $host_socket,
      registry_mirror => $registry_mirror,
      command         => $command,
    })

    $exec_create = "${docker_command} create --name ${docker_service_create_flags}"
    $unless_create = "docker service ps ${service_name}"

    exec { "${title} docker service create":
      command     => $exec_create,
      environment => $exec_environment,
      path        => $exec_path,
      timeout     => $exec_timeout,
      provider    => $exec_provider,
      unless      => $unless_create,
    }
  }

  if $update {
    $docker_service_flags = docker_service_flags({
      detach          => $detach,
      env             => any2array($env),
      service_name    => $service_name,
      label           => any2array($label),
      publish         => $publish,
      replicas        => $replicas,
      tty             => $tty,
      user            => $user,
      workdir         => $workdir,
      extra_params    => any2array($extra_params),
      image           => $image,
      host_socket     => $host_socket,
      registry_mirror => $registry_mirror,
    })

    $exec_update = "${docker_command} update ${docker_service_flags}"

    exec { "${title} docker service update":
      command     => $exec_update,
      environment => $exec_environment,
      path        => $exec_path,
      provider    => $exec_provider,
      timeout     => $exec_timeout,
    }
  }

  if $scale {
    $docker_service_flags = docker_service_flags({
      service_name => $service_name,
      replicas     => $replicas,
      extra_params => any2array($extra_params),
    })

    $exec_scale = "${docker_command} scale ${service_name}=${replicas}"

    exec { "${title} docker service scale":
      command     => $exec_scale,
      environment => $exec_environment,
      path        => $exec_path,
      timeout     => $exec_timeout,
      provider    => $exec_provider,
    }
  }

  if $ensure == 'absent' {
    exec { "${title} docker service remove":
      command  => "docker service rm ${service_name}",
      onlyif   => "docker service ps ${service_name}",
      path     => $exec_path,
      provider => $exec_provider,
      timeout  => $exec_timeout,
    }
  }
}
