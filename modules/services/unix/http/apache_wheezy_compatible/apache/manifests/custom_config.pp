# See README.md for usage information
define apache::custom_config (
  $ensure         = 'present',
  $confdir        = $::apache::confd_dir,
  $content        = undef,
  $priority       = '25',
  $source         = undef,
  $verify_command = $::apache::params::verify_command,
  $verify_config  = true,
  $filename       = undef,
) {

  if $content and $source {
    fail('Only one of $content and $source can be specified.')
  }

  if $ensure == 'present' and ! $content and ! $source {
    fail('One of $content and $source must be specified.')
  }

  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure.
  Allowed values are 'present' and 'absent'.")

  validate_bool($verify_config)

  if $filename {
    $_filename = $filename
  } else {
    if $priority {
      $priority_prefix = "${priority}-"
    } else {
      $priority_prefix = ''
    }

    ## Apache include does not always work with spaces in the filename
    $filename_middle = regsubst($name, ' ', '_', 'G')
    $_filename = "${priority_prefix}${filename_middle}.conf"
  }

  if ! $verify_config or $ensure == 'absent' {
    $notifies = Class['Apache::Service']
  } else {
    $notifies = undef
  }

  file { "apache_${name}":
    ensure  => $ensure,
    path    => "${confdir}/${_filename}",
    content => $content,
    source  => $source,
    require => Package['httpd'],
    notify  => $notifies,
  }

  if $ensure == 'present' and $verify_config {
    exec { "syntax verification for ${name}":
      command     => $verify_command,
      subscribe   => File["apache_${name}"],
      refreshonly => true,
      notify      => Class['Apache::Service'],
      before      => Exec["remove ${name} if invalid"],
      require     => Anchor['::apache::modules_set_up'],
    }

    exec { "remove ${name} if invalid":
      command     => "/bin/rm ${confdir}/${_filename}",
      unless      => $verify_command,
      subscribe   => File["apache_${name}"],
      refreshonly => true,
    }
  }
}
