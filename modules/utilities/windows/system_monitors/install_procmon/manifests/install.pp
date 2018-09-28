class install_procmon::install {
  include chocolatey

  package { 'procmon':
    ensure   => installed,
    provider => 'chocolatey',
  }
}