# Class: nginx
#
# This module manages NGINX.
#
# Parameters:
#
# Actions:
#
# Requires:
#  puppetlabs-stdlib - https://github.com/puppetlabs/puppetlabs-stdlib
#
#  Packaged NGINX
#    - RHEL: EPEL or custom package
#    - Debian/Ubuntu: Default Install or custom package
#    - SuSE: Default Install or custom package
#
#  stdlib
#    - puppetlabs-stdlib module >= 0.1.6
#    - plugin sync enabled to obtain the anchor type
#
# Sample Usage:
#
# The module works with sensible defaults:
#
# node default {
#   include nginx
# }
class nginx (
  ### START Nginx Configuration ###
  $client_body_buffer_size        = undef,
  $client_body_temp_path          = undef,
  $client_max_body_size           = undef,
  $events_use                     = undef,
  $fastcgi_cache_inactive         = undef,
  $fastcgi_cache_key              = undef,
  $fastcgi_cache_keys_zone        = undef,
  $fastcgi_cache_levels           = undef,
  $fastcgi_cache_max_size         = undef,
  $fastcgi_cache_path             = undef,
  $fastcgi_cache_use_stale        = undef,
  $gzip                           = undef,
  $http_cfg_append                = undef,
  $http_tcp_nodelay               = undef,
  $http_tcp_nopush                = undef,
  $keepalive_timeout              = undef,
  $mail                           = undef,
  $multi_accept                   = undef,
  $names_hash_bucket_size         = undef,
  $names_hash_max_size            = undef,
  $proxy_buffers                  = undef,
  $proxy_buffer_size              = undef,
  $proxy_cache_inactive           = undef,
  $proxy_cache_keys_zone          = undef,
  $proxy_cache_levels             = undef,
  $proxy_cache_max_size           = undef,
  $proxy_cache_path               = undef,
  $proxy_connect_timeout          = undef,
  $proxy_headers_hash_bucket_size = undef,
  $proxy_http_version             = undef,
  $proxy_read_timeout             = undef,
  $proxy_redirect                 = undef,
  $proxy_send_timeout             = undef,
  $proxy_set_header               = undef,
  $sendfile                       = undef,
  $server_tokens                  = undef,
  $spdy                           = undef,
  $types_hash_bucket_size         = undef,
  $types_hash_max_size            = undef,
  $worker_connections             = undef,
  $worker_processes               = undef,
  $worker_rlimit_nofile           = undef,
  ### END Nginx Configuration

  ### START Module/App Configuration ###
  $confd_purge                    = undef,
  $conf_dir                       = undef,
  $daemon_user                    = undef,
  $global_owner                   = undef,
  $global_group                   = undef,
  $global_mode                    = undef,
  $logdir                         = undef,
  $log_format                     = undef,
  $http_access_log                = undef,
  $nginx_error_log                = undef,
  $pid                            = undef,
  $proxy_temp_path                = undef,
  $root_group                     = undef,
  $run_dir                        = undef,
  $sites_available_owner          = undef,
  $sites_available_group          = undef,
  $sites_available_mode           = undef,
  $super_user                     = undef,
  $temp_dir                       = undef,
  $vhost_purge                    = undef,

  # Primary Templates
  $conf_template                  = undef,
  $proxy_conf_template            = undef,
  ### END Module/App Configuration ###

  ### START Package Configuration ###
  $package_ensure                 = present,
  $package_name                   = $::nginx::params::package_name,
  $package_source                 = 'nginx',
  $package_flavor                 = undef,
  $manage_repo                    = $::nginx::params::manage_repo,
  ### END Package Configuration ###

  ### START Service Configuation ###
  $configtest_enable              = false,
  $service_ensure                 = running,
  $service_flags                  = undef,
  $service_restart                = '/etc/init.d/nginx reload',
  $service_name                   = undef,
  ### END Service Configuration ###

  ### START Hiera Lookups ###
  $geo_mappings                   = {},
  $string_mappings                = {},
  $nginx_locations                = {},
  $nginx_mailhosts                = {},
  $nginx_upstreams                = {},
  $nginx_vhosts                   = {},
  $nginx_vhosts_defaults          = {},
  ### END Hiera Lookups ###
) inherits ::nginx::params {

  ### DEPRECATION WARNING ###
  ###
  ### During the transition from the params pattern -> puppet-module-data,
  ### we need a graceful way to notify the consumer that the pattern is
  ### changing, and point them toward docs on how to transition.
  ###
  ### Once we hit 1.0, this whole block goes away.
  ###
  ### Please note: as a contributor to this module, no Pulls will be accepted
  ### that do add additional parameters to this class. Get on this puppet-module-data
  ### level!

  ### This block makes me sad, but what can you do.... we need to do this
  ### migration the Right Way(tm) -- JDF

  if $client_body_buffer_size or
        $client_body_temp_path or
        $client_max_body_size or
        $confd_purge or
        $conf_dir or
        $conf_template or
        $daemon_user or
        $events_use or
        $fastcgi_cache_inactive or
        $fastcgi_cache_key or
        $fastcgi_cache_keys_zone or
        $fastcgi_cache_levels or
        $fastcgi_cache_max_size or
        $fastcgi_cache_path or
        $fastcgi_cache_use_stale or
        $gzip or
        $http_access_log or
        $http_cfg_append or
        $http_tcp_nodelay or
        $http_tcp_nopush or
        $keepalive_timeout or
        $logdir or
        $log_format or
        $mail or
        $multi_accept or
        $names_hash_bucket_size or
        $names_hash_max_size or
        $nginx_error_log or
        $pid or
        $proxy_buffers or
        $proxy_buffer_size or
        $proxy_cache_inactive or
        $proxy_cache_keys_zone or
        $proxy_cache_levels or
        $proxy_cache_max_size or
        $proxy_cache_path or
        $proxy_conf_template or
        $proxy_connect_timeout or
        $proxy_headers_hash_bucket_size or
        $proxy_http_version or
        $proxy_read_timeout or
        $proxy_redirect or
        $proxy_send_timeout or
        $proxy_set_header or
        $proxy_temp_path or
        $run_dir or
        $sendfile or
        $server_tokens or
        $spdy or
        $super_user or
        $temp_dir or
        $types_hash_bucket_size or
        $types_hash_max_size or
        $vhost_purge or
        $worker_connections or
        $worker_processes or
        $worker_rlimit_nofile or
        $global_owner or
        $global_group or
        $global_mode or
        $sites_available_owner or
        $sites_available_group or
        $sites_available_mode {
          include ::nginx::notice::config
        }

  ### END DEPRECATION WARNING ###

  class { '::nginx::package':
    package_name   => $package_name,
    package_source => $package_source,
    package_ensure => $package_ensure,
    package_flavor => $package_flavor,
    notify         => Class['::nginx::service'],
    manage_repo    => $manage_repo,
  }

  ## This `if` statement is here in the event a user cannot use
  ## Hiera based parameter overrides. Will not be here in 1.0 release
  if !defined(Class['::nginx::config']) {
    class { '::nginx::config':
      client_body_buffer_size        => $client_body_buffer_size,
      client_body_temp_path          => $client_body_temp_path,
      client_max_body_size           => $client_max_body_size,
      confd_purge                    => $confd_purge,
      conf_dir                       => $conf_dir,
      conf_template                  => $conf_template,
      daemon_user                    => $daemon_user,
      events_use                     => $events_use,
      fastcgi_cache_inactive         => $fastcgi_cache_inactive,
      fastcgi_cache_key              => $fastcgi_cache_key,
      fastcgi_cache_keys_zone        => $fastcgi_cache_keys_zone,
      fastcgi_cache_levels           => $fastcgi_cache_levels,
      fastcgi_cache_max_size         => $fastcgi_cache_max_size,
      fastcgi_cache_path             => $fastcgi_cache_path,
      fastcgi_cache_use_stale        => $fastcgi_cache_use_stale,
      gzip                           => $gzip,
      http_access_log                => $http_access_log,
      http_cfg_append                => $http_cfg_append,
      http_tcp_nodelay               => $http_tcp_nodelay,
      http_tcp_nopush                => $http_tcp_nopush,
      keepalive_timeout              => $keepalive_timeout,
      log_dir                        => $logdir,
      log_format                     => $log_format,
      mail                           => $mail,
      multi_accept                   => $multi_accept,
      names_hash_bucket_size         => $names_hash_bucket_size,
      names_hash_max_size            => $names_hash_max_size,
      nginx_error_log                => $nginx_error_log,
      pid                            => $pid,
      proxy_buffers                  => $proxy_buffers,
      proxy_buffer_size              => $proxy_buffer_size,
      proxy_cache_inactive           => $proxy_cache_inactive,
      proxy_cache_keys_zone          => $proxy_cache_keys_zone,
      proxy_cache_levels             => $proxy_cache_levels,
      proxy_cache_max_size           => $proxy_cache_max_size,
      proxy_cache_path               => $proxy_cache_path,
      proxy_conf_template            => $proxy_conf_template,
      proxy_connect_timeout          => $proxy_connect_timeout,
      proxy_headers_hash_bucket_size => $proxy_headers_hash_bucket_size,
      proxy_http_version             => $proxy_http_version,
      proxy_read_timeout             => $proxy_read_timeout,
      proxy_redirect                 => $proxy_redirect,
      proxy_send_timeout             => $proxy_send_timeout,
      proxy_set_header               => $proxy_set_header,
      proxy_temp_path                => $proxy_temp_path,
      run_dir                        => $run_dir,
      sendfile                       => $sendfile,
      server_tokens                  => $server_tokens,
      spdy                           => $spdy,
      super_user                     => $super_user,
      temp_dir                       => $temp_dir,
      types_hash_bucket_size         => $types_hash_bucket_size,
      types_hash_max_size            => $types_hash_max_size,
      vhost_purge                    => $vhost_purge,
      worker_connections             => $worker_connections,
      worker_processes               => $worker_processes,
      worker_rlimit_nofile           => $worker_rlimit_nofile,
      global_owner                   => $global_owner,
      global_group                   => $global_group,
      global_mode                    => $global_mode,
      sites_available_owner          => $sites_available_owner,
      sites_available_group          => $sites_available_group,
      sites_available_mode           => $sites_available_mode,
    }
  }
  Class['::nginx::package'] -> Class['::nginx::config'] ~> Class['::nginx::service']

  class { '::nginx::service':
    configtest_enable => $configtest_enable,
    service_ensure    => $service_ensure,
    service_restart   => $service_restart,
    service_name      => $service_name,
    service_flags     => $service_flags,
  }

  create_resources('nginx::resource::upstream', $nginx_upstreams)
  create_resources('nginx::resource::vhost', $nginx_vhosts, $nginx_vhosts_defaults)
  create_resources('nginx::resource::location', $nginx_locations)
  create_resources('nginx::resource::mailhost', $nginx_mailhosts)
  create_resources('nginx::resource::map', $string_mappings)
  create_resources('nginx::resource::geo', $geo_mappings)

  # Allow the end user to establish relationships to the "main" class
  # and preserve the relationship to the implementation classes through
  # a transitive relationship to the composite class.
  anchor{ 'nginx::begin':
    before => Class['::nginx::package'],
    notify => Class['::nginx::service'],
  }
  anchor { 'nginx::end':
    require => Class['::nginx::service'],
  }
}
