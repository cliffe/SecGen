class gnome::install {
  # task-gnome-desktop pulls in gnome-shell and the gdm3 login manager.
  # Puppet's apt provider runs non-interactively, so the "default display
  # manager" prompt (gdm3 vs sddm on the KDE desktop bases) keeps sddm.
  if $facts['os']['name'] == 'Debian' {
    package { 'task-gnome-desktop':
      ensure => 'installed',
    }
  }
}
