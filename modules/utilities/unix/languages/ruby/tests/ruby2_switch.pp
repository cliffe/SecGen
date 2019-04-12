class { '::ruby':
  version         => '2.0.0',
  latest_release  => true,
  rubygems_update => true,
}
include ::ruby::dev
