# docker::volumes
class docker::volumes($volumes) {
  create_resources(docker_volumes, $volumes)
}
