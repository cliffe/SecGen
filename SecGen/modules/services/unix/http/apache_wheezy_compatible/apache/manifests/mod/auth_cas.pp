class apache::mod::auth_cas (
  $cas_login_url,
  $cas_validate_url,
  $cas_cookie_path           = $::apache::params::cas_cookie_path,
  $cas_cookie_path_mode      = '0750',
  $cas_version               = 2,
  $cas_debug                 = 'Off',
  $cas_validate_server       = undef,
  $cas_validate_depth        = undef,
  $cas_certificate_path      = undef,
  $cas_proxy_validate_url    = undef,
  $cas_root_proxied_as       = undef,
  $cas_cookie_entropy        = undef,
  $cas_timeout               = undef,
  $cas_idle_timeout          = undef,
  $cas_cache_clean_interval  = undef,
  $cas_cookie_domain         = undef,
  $cas_cookie_http_only      = undef,
  $cas_authoritative         = undef,
  $cas_validate_saml         = undef,
  $cas_sso_enabled           = undef,
  $cas_attribute_prefix      = undef,
  $cas_attribute_delimiter   = undef,
  $cas_scrub_request_headers = undef,
  $suppress_warning          = false,
) inherits ::apache::params {

  validate_string($cas_login_url, $cas_validate_url, $cas_cookie_path)

  if $::osfamily == 'RedHat' and ! $suppress_warning {
    warning('RedHat distributions do not have Apache mod_auth_cas in their default package repositories.')
  }

  include ::apache
  ::apache::mod { 'auth_cas': }

  file { $cas_cookie_path:
    ensure => directory,
    before => File['auth_cas.conf'],
    mode   => $cas_cookie_path_mode,
    owner  => $apache::user,
    group  => $apache::group,
  }

  # Template uses
  # - All variables beginning with cas_
  file { 'auth_cas.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/auth_cas.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/auth_cas.conf.erb'),
    require => [ Exec["mkdir ${::apache::mod_dir}"], ],
    before  => File[$::apache::mod_dir],
    notify  => Class['Apache::Service'],
  }

}
