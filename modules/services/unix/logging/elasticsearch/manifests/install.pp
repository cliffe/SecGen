class elasticsearch::install (
  String $package_url  = 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.10.0-amd64.deb',
  String $version = '7.10.0',
) {

  Exec { path => ['/bin','/sbin','/usr/bin', '/usr/sbin'] }

  # The local package mirror serves the apt/yum repositories but not the
  # root GPG-KEY file, so fetch the key from upstream directly (as the docker,
  # filebeat and auditbeat modules do) and mirror only the repository.
  $key_url = 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  $repo_url = secgen_functions::mirror_url('https://artifacts.elastic.co/packages/7.x/apt')

  # apt-key and sudo are not reliably present on Debian bookworm: use a
  # dearmored keyring and signed-by instead
  ensure_packages(['wget', 'gnupg', 'apt-transport-https', 'ca-certificates'])

  # The bundled puppetlabs-java modules have no Debian 12 (bookworm) support
  # ('unsupported release 12'), so install the distribution JRE directly.
  # Elasticsearch 7.10.0 ships its own JDK; this provides `java` on the PATH.
  ensure_packages(['openjdk-17-jre-headless'])

  # Install Elasticsearch
  # bounded wget (timeout + retries) so a stalled fetch fails fast instead of
  # hanging until Puppet's exec timeout
  exec { 'es add gpg key':
    command => "wget -q --timeout=30 --tries=3 -O - ${key_url} | gpg --batch --yes --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg",
    creates => '/usr/share/keyrings/elasticsearch-keyring.gpg',
    require => Package['wget', 'gnupg', 'ca-certificates'],
  }->
  file { '/etc/apt/sources.list.d/elastic-7.x.list':
    ensure  => file,
    content => "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] ${repo_url} stable main\n",
  }->
  exec { 'es update apt':
    command => 'apt-get update',
  }->
  # pinned: the 7.x repository otherwise installs the latest 7.17.x
  package { 'elasticsearch':
    ensure => $version,
  }
}
