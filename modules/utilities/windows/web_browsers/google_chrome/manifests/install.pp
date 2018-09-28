class google_chrome::install {
  include chocolatey

  notice('Installing google chrome')

  package { 'googlechrome':
    ensure   => installed,
    provider => 'chocolatey',
  }
}