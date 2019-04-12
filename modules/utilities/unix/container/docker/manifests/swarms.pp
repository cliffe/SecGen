# docker::swarms
class docker::swarms($swarms) {
  create_resources(docker::swarm, $swarms)
}
