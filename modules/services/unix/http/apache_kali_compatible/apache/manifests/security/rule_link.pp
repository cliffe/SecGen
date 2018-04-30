define apache::security::rule_link () {

  $parts = split($title, '/')
  $filename = $parts[-1]

  $target = $title ? {
    /^\//   => $title,
    default => "${::apache::params::modsec_crs_path}/${title}",
  }

  file { $filename:
    ensure  => 'link',
    path    => "${::apache::mod::security::modsec_dir}/activated_rules/${filename}",
    target  => $target ,
    require => File["${::apache::mod::security::modsec_dir}/activated_rules"],
    notify  => Class['apache::service'],
  }
}
