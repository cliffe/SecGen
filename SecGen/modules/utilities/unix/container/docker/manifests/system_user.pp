# == Define: docker::system_user
#
# Define to manage docker group users
#
# === Parameters
# [*create_user*]
#   Boolean to cotrol whether the user should be created
#
define docker::system_user (
  $create_user = true) {

  include docker
  $docker_group = $docker::docker_group

  if $create_user {
    ensure_resource('user', $name, {'ensure' => 'present' })
    User[$name] -> Exec["docker-system-user-${name}"]
  }

  exec { "docker-system-user-${name}":
    command => "/usr/sbin/usermod -aG ${docker_group} ${name}",
    unless  => "/bin/cat /etc/group | grep '^${docker_group}:' | grep -qw ${name}",
  }
}
