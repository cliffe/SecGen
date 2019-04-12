# == Class: docker::config
#
class docker::config {
  if $::osfamily != 'windows' {
    docker::system_user { $docker::docker_users: }
  } else {
    docker::windows_account { $docker::docker_users: }
  }
}
