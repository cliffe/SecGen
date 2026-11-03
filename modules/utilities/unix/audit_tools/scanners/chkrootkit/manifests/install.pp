class chkrootkit::install {
  # chkrootkit exits before scanning if any helper it shells out to
  # (strings, netstat, ps) is missing, so declare them explicitly rather
  # than relying on the package's dependency/recommends resolution.
  ensure_packages(['binutils', 'net-tools', 'procps'])

  package { 'chkrootkit':
    ensure  => installed,
    require => Package['binutils', 'net-tools', 'procps'],
  }
}
