class { 'python':
  version    => 'system',
  pip        => 'present',
  dev        => 'absent',
  virtualenv => 'absent',
  gunicorn   => 'absent',
}