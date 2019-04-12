class { '::ruby':
  version         => '1.9.3',
  latest_release  => true,
  rubygems_update => true,
}
include ::ruby::dev
