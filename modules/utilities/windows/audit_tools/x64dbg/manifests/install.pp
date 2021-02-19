class x64dbg::install {
  package { 'x64dbg.portable':
    provider => chocolatey,
    ensure => installed,
  }
}
