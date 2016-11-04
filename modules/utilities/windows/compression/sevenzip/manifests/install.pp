class sevenzip::install {
  package { '7zip':
    ensure => installed,
    provider => chocolatey,
  }
}