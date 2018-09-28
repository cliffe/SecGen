class sqlite_browser::install {
  include chocolatey

  notice('Installing Sqlite browser')

  package { 'sqlitebrowser':
    ensure   => installed,
    provider => 'chocolatey',
  }

  notice('Sqlite browser install finished')
}