class ollydbg::install {
  package { 'ollydbg':
    provider => chocolatey,
    ensure => installed,
  }
}
