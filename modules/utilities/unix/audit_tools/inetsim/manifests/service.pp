# Starts INetSim now and at boot, restarting it when its config changes.
class inetsim::service {
  service { 'inetsim':
    ensure    => running,
    enable    => true,
    subscribe => Class['inetsim::config'],
  }
}
