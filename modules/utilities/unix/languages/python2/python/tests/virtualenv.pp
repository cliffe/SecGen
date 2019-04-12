class { 'python':
  version    => 'system',
  dev        => true,
  virtualenv => true,
}

python::virtualenv { '/var/www/project1':
  ensure       => present,
  version      => 'system',
  requirements => '/var/www/project1/requirements.txt',
  proxy        => 'http://proxy.domain.com:3128',
  systempkgs   => true,
}
