# See README.md for usage information
define apache::vhost::custom(
  $content,
  $ensure = 'present',
  $priority = '25',
  $verify_config = true,
) {
  include ::apache

  ## Apache include does not always work with spaces in the filename
  $filename = regsubst($name, ' ', '_', 'G')

  ::apache::custom_config { $filename:
    ensure        => $ensure,
    confdir       => $::apache::vhost_dir,
    content       => $content,
    priority      => $priority,
    verify_config => $verify_config,
  }

  # NOTE(pabelanger): This code is duplicated in ::apache::vhost and needs to
  # converted into something generic.
  if $::apache::vhost_enable_dir {
    $vhost_symlink_ensure = $ensure ? {
      present => link,
      default => $ensure,
    }

    file { "${priority}-${filename}.conf symlink":
      ensure  => $vhost_symlink_ensure,
      path    => "${::apache::vhost_enable_dir}/${priority}-${filename}.conf",
      target  => "${::apache::vhost_dir}/${priority}-${filename}.conf",
      owner   => 'root',
      group   => $::apache::params::root_group,
      mode    => $::apache::file_mode,
      require => Apache::Custom_config[$filename],
      notify  => Class['apache::service'],
    }
  }
}
