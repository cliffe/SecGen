# docker::registry_auth
class docker::registry_auth($registries) {
  create_resources(docker::registry, $registries)
}
