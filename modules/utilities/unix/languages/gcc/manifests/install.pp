class gcc::install {

  if $operatingsystemrelease == 'kali-rolling' {
      # first remove the currently installed gcc versions
    package { 'libgcc-9-dev':
      ensure => 'purged',
    }
  }

  # build-essential already depends on g++ and make; they are listed so that
  # other modules (and the secgen_test) can rely on them being present.
  package { ['gcc-multilib', 'build-essential', 'g++', 'make']:
    ensure => 'installed',
  }
}
