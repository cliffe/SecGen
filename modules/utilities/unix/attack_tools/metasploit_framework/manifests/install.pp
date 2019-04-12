class metasploit_framework::install{
  package { ['metasploit-framework']:
    ensure => 'installed',
  }
}
