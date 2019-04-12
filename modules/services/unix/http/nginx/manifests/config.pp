# Class: nginx::config
#
# This module manages NGINX bootstrap and configuration
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::config(
  ### START Module/App Configuration ###
  $client_body_temp_path          = $::nginx::params::client_body_temp_path,
  $confd_purge                    = false,
  $conf_dir                       = $::nginx::params::conf_dir,
  $daemon_user                    = $::nginx::params::daemon_user,
  $global_owner                   = $::nginx::params::global_owner,
  $global_group                   = $::nginx::params::global_group,
  $global_mode                    = $::nginx::params::global_mode,
  $log_dir                        = $::nginx::params::log_dir,
  $http_access_log                = $::nginx::params::http_access_log,
  $nginx_error_log                = $::nginx::params::nginx_error_log,
  $nginx_error_log_severity       = 'error',
  $pid                            = $::nginx::params::pid,
  $proxy_temp_path                = $::nginx::params::proxy_temp_path,
  $root_group                     = $::nginx::params::root_group,
  $run_dir                        = $::nginx::params::run_dir,
  $sites_available_owner          = $::nginx::params::sites_available_owner,
  $sites_available_group          = $::nginx::params::sites_available_group,
  $sites_available_mode           = $::nginx::params::sites_available_mode,
  $super_user                     = $::nginx::params::super_user,
  $temp_dir                       = $::nginx::params::temp_dir,
  $vhost_purge                    = false,

  # Primary Templates
  $conf_template                  = 'nginx/conf.d/nginx.conf.erb',
  $proxy_conf_template            = undef,
  ### END Module/App Configuration ###

  ### START Nginx Configuration ###
  $client_body_buffer_size        = '128k',
  $client_max_body_size           = '10m',
  $events_use                     = false,
  $fastcgi_cache_inactive         = '20m',
  $fastcgi_cache_key              = false,
  $fastcgi_cache_keys_zone        = 'd3:100m',
  $fastcgi_cache_levels           = '1',
  $fastcgi_cache_max_size         = '500m',
  $fastcgi_cache_path             = false,
  $fastcgi_cache_use_stale        = false,
  $gzip                           = 'on',
  $gzip_buffers                   = undef,
  $gzip_comp_level                = 1,
  $gzip_disable                   = 'msie6',
  $gzip_min_length                = 20,
  $gzip_http_version              = 1.1,
  $gzip_proxied                   = 'off',
  $gzip_types                     = 'text/html',
  $gzip_vary                      = 'off',
  $http_cfg_append                = false,
  $http_tcp_nodelay               = 'on',
  $http_tcp_nopush                = 'off',
  $keepalive_timeout              = '65',
  $log_format                     = {},
  $mail                           = false,
  $stream                         = false,
  $multi_accept                   = 'off',
  $names_hash_bucket_size         = '64',
  $names_hash_max_size            = '512',
  $nginx_cfg_prepend              = false,
  $proxy_buffers                  = '32 4k',
  $proxy_buffer_size              = '8k',
  $proxy_cache_inactive           = '20m',
  $proxy_cache_keys_zone          = 'd2:100m',
  $proxy_cache_levels             = '1',
  $proxy_cache_max_size           = '500m',
  $proxy_cache_path               = false,
  $proxy_connect_timeout          = '90',
  $proxy_headers_hash_bucket_size = '64',
  $proxy_http_version             = undef,
  $proxy_read_timeout             = '90',
  $proxy_redirect                 = 'off',
  $proxy_send_timeout             = '90',
  $proxy_set_header               = [
    'Host $host',
    'X-Real-IP $remote_addr',
    'X-Forwarded-For $proxy_add_x_forwarded_for',
  ],
  $sendfile                       = 'on',
  $server_tokens                  = 'on',
  $spdy                           = 'off',
  $http2                          = 'off',
  $ssl_stapling                   = 'off',
  $types_hash_bucket_size         = '512',
  $types_hash_max_size            = '1024',
  $worker_connections             = '1024',
  $worker_processes               = '1',
  $worker_rlimit_nofile           = '1024',
  ### END Nginx Configuration ###
) inherits ::nginx::params {

  ### Validations ###
  if ($worker_processes != 'auto') and (!is_integer($worker_processes)) {
    fail('$worker_processes must be an integer or have value "auto".')
  }
  if (!is_integer($worker_connections)) {
    fail('$worker_connections must be an integer.')
  }
  if (!is_integer($worker_rlimit_nofile)) {
    fail('$worker_rlimit_nofile must be an integer.')
  }
  if (!is_string($events_use)) and ($events_use != false) {
    fail('$events_use must be a string or false.')
  }
  validate_string($multi_accept)
  validate_array($proxy_set_header)
  if ($proxy_http_version != undef) {
    validate_string($proxy_http_version)
  }
  if ($proxy_conf_template != undef) {
    warn('The $proxy_conf_template parameter is deprecated and has no effect.')
  }
  validate_bool($confd_purge)
  validate_bool($vhost_purge)
  if ( $proxy_cache_path != false) {
    if ( is_string($proxy_cache_path) or is_hash($proxy_cache_path)) {}
    else {
      fail('proxy_cache_path must be a string or a hash')
    }
  }
  validate_re($proxy_cache_levels, '^[12](:[12])*$')
  validate_string($proxy_cache_keys_zone)
  validate_string($proxy_cache_max_size)
  validate_string($proxy_cache_inactive)

  if ($fastcgi_cache_path != false) {
        validate_string($fastcgi_cache_path)
  }
  validate_re($fastcgi_cache_levels, '^[12](:[12])*$')
  validate_string($fastcgi_cache_keys_zone)
  validate_string($fastcgi_cache_max_size)
  validate_string($fastcgi_cache_inactive)
  if ($fastcgi_cache_key != false) {
    validate_string($fastcgi_cache_key)
  }
  if ($fastcgi_cache_use_stale != false) {
    validate_string($fastcgi_cache_use_stale)
  }

  validate_bool($mail)
  validate_string($server_tokens)
  validate_string($client_max_body_size)
  if (!is_integer($names_hash_bucket_size)) {
    fail('$names_hash_bucket_size must be an integer.')
  }
  if (!is_integer($names_hash_max_size)) {
    fail('$names_hash_max_size must be an integer.')
  }
  validate_string($proxy_buffers)
  validate_string($proxy_buffer_size)
  if ($http_cfg_append != false) {
    if !(is_hash($http_cfg_append) or is_array($http_cfg_append)) {
      fail('$http_cfg_append must be either a hash or array')
    }
  }

  if ($nginx_cfg_prepend != false) {
    if !(is_hash($nginx_cfg_prepend) or is_array($nginx_cfg_prepend)) {
      fail('$nginx_cfg_prepend must be either a hash or array')
    }
  }

  validate_string($nginx_error_log)
  validate_re($nginx_error_log_severity,['debug','info','notice','warn','error','crit','alert','emerg'],'$nginx_error_log_severity must be debug, info, notice, warn, error, crit, alert or emerg')
  validate_string($http_access_log)
  validate_string($proxy_headers_hash_bucket_size)
  validate_bool($super_user)
  ### END VALIDATIONS ###


  ### CONFIGURATION ###
  File {
    owner => $global_owner,
    group => $global_group,
    mode  => $global_mode,
  }

  file { $conf_dir:
    ensure => directory,
  }

  file { "${conf_dir}/conf.stream.d":
    ensure => directory,
  }
  if $confd_purge == true {
    File["${conf_dir}/conf.stream.d"] {
      purge   => true,
      recurse => true,
    }
  }

  file { "${conf_dir}/conf.d":
    ensure => directory,
  }
  if $confd_purge == true {
    File["${conf_dir}/conf.d"] {
      purge   => true,
      recurse => true,
      notify  => Class['::nginx::service'],
    }
  }

  file { "${conf_dir}/conf.mail.d":
    ensure => directory,
  }
  if $confd_purge == true {
    File["${conf_dir}/conf.mail.d"] {
      purge   => true,
      recurse => true,
    }
  }

  file { "${conf_dir}/conf.d/vhost_autogen.conf":
    ensure => absent,
  }

  file { "${conf_dir}/conf.mail.d/vhost_autogen.conf":
    ensure => absent,
  }

  file {$run_dir:
    ensure => directory,
  }

  file { $log_dir:
    ensure => directory,
  }

  file {$client_body_temp_path:
    ensure => directory,
    owner  => $daemon_user,
  }

  file {$proxy_temp_path:
    ensure => directory,
    owner  => $daemon_user,
  }

  file { "${conf_dir}/sites-available":
    ensure => directory,
    owner  => $sites_available_owner,
    group  => $sites_available_group,
    mode   => $sites_available_mode,
  }

  if $vhost_purge == true {
    File["${conf_dir}/sites-available"] {
      purge   => true,
      recurse => true,
    }
  }

  file { "${conf_dir}/sites-enabled":
    ensure => directory,
  }

  if $vhost_purge == true {
    File["${conf_dir}/sites-enabled"] {
      purge   => true,
      recurse => true,
    }
  }

  file { "${conf_dir}/sites-enabled/default":
    ensure => absent,
  }

  file { "${conf_dir}/nginx.conf":
    ensure  => file,
    content => template($conf_template),
  }

  file { "${conf_dir}/conf.d/proxy.conf":
    ensure  => absent,
  }

  file { "${conf_dir}/conf.d/default.conf":
    ensure => absent,
  }

  file { "${conf_dir}/conf.d/example_ssl.conf":
    ensure => absent,
  }

  file { "${temp_dir}/nginx.d":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }

  file { "${temp_dir}/nginx.mail.d":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }
}
