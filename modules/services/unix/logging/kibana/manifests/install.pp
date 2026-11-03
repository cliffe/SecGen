class kibana::install () {
  Exec { path => ['/bin','/sbin','/usr/bin', '/usr/sbin'] }

  # Kibana is not in Debian's repositories: add Elastic's 7.x apt repo.
  # The keyring and list paths are shared with the elasticsearch module so
  # that on a combined VM both use the same key and repo file.
  $key_url  = 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  $repo_url = secgen_functions::mirror_url('https://artifacts.elastic.co/packages/7.x/apt')

  ensure_packages(['wget', 'gnupg', 'apt-transport-https', 'ca-certificates'])

  exec { 'kibana add gpg key':
    command => "wget -q --timeout=30 --tries=3 -O - ${key_url} | gpg --batch --yes --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg",
    creates => '/usr/share/keyrings/elasticsearch-keyring.gpg',
    require => Package['wget', 'gnupg', 'ca-certificates'],
  }->
  exec { 'kibana add apt repository':
    command => "echo \"deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] ${repo_url} stable main\" > /etc/apt/sources.list.d/elastic-7.x.list",
    creates => '/etc/apt/sources.list.d/elastic-7.x.list',
  }->
  exec { 'kibana update apt':
    command => 'apt-get update',
    unless  => 'dpkg -s kibana 2>/dev/null | grep -q "^Status: install ok installed"',
  }->
  # Pinned to the elasticsearch module's version: Kibana refuses (503) an
  # Elasticsearch older than itself, and the 7.x repo's newest is 7.17.
  package { 'kibana':
    ensure => '7.10.0',
  }
}
