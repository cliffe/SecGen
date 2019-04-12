class { 'python':
  version    => 'system',
  dev        => true,
  virtualenv => true,
}

python::gunicorn { 'vhost':
  ensure      => present,
  virtualenv  => '/var/www/project1',
  mode        => 'wsgi',
  dir         => '/var/www/project1/current',
  bind        => 'unix:/tmp/gunicorn.socket',
  environment => 'prod',
  appmodule   => 'app:app',
  osenv       => {
    'DBHOST' => 'dbserver.example.com'
  },
  timeout     => 30,
  template    => 'python/gunicorn.erb',
}
