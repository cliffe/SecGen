class gcc::install {

  if $operatingsystemrelease == 'kali-rolling' {
      # first remove the currently installed gcc versions
    package { 'libgcc-9-dev':
      ensure => 'purged',
    }
  }


  package { ['gcc-multilib', 'build-essential']:
    ensure => 'installed',
  }
}
