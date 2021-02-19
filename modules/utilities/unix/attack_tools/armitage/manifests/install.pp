class armitage::install{
  package { ['armitage']:
    ensure => 'installed',
  }
  ensure_packages("xtightvncviewer")
}
