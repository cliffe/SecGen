class elasticsearch::install (
  String $package_url  = 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.10.0-amd64.deb',
) {

  Exec { path => ['/bin','/sbin','/usr/bin', '/usr/sbin'] }

  # Install Elasticsearch
  exec { 'es add gpg key':
   command => 'wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -'
  }->
  exec { 'es add apt repository':
    command => 'echo "deb http://172.33.0.44/artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list'
  }->
  exec { 'es update apt':
    command => 'apt-get update'
  }->
  package { 'elasticsearch':
    ensure => present,
  }
}
