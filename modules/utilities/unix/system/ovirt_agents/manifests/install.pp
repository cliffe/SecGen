class ovirt_agents::install{
  package { ['ovirt-guest-agent', 'spice-vdagent']:
    ensure => 'installed',
  }
}
