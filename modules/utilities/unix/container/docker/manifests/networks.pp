# docker::networks
class docker::networks($networks) {
  create_resources(docker_network, $networks)
}
