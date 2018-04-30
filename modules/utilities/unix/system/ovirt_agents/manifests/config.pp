class ovirt_agents::config{
  service { 'ovirt-guest-agent':
    enable => true,
    ensure => 'running',
  }
  service { 'spice-vdagent':
    enable => true,
    ensure => 'running',
  }
}
