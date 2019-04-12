# Class: apache::params
#
# This class manages Apache parameters
#
# Parameters:
# - The $user that Apache runs as
# - The $group that Apache runs as
# - The $apache_name is the name of the package and service on the relevant
#   distribution
# - The $php_package is the name of the package that provided PHP
# - The $ssl_package is the name of the Apache SSL package
# - The $apache_dev is the name of the Apache development libraries package
# - The $conf_contents is the contents of the Apache configuration file
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class apache::params inherits ::apache::version {
  if($::fqdn) {
    $servername = $::fqdn
  } else {
    $servername = $::hostname
  }

  # The default error log level
  $log_level = 'warn'
  $use_optional_includes = false

  # Default mime types settings
  $mime_types_additional = {
    'AddHandler'      => { 'type-map'  => 'var', },
    'AddType'         => { 'text/html' => '.shtml', },
    'AddOutputFilter' => { 'INCLUDES'  => '.shtml', },
  }

  # should we use systemd module?
  $use_systemd = true

  # Default mode for files
  $file_mode = '0644'

  # Default options for / directory
  $root_directory_options = ['FollowSymLinks']

  $vhost_include_pattern = '*'

  $modsec_audit_log_parts = 'ABIJDEFHZ'

  if ($::operatingsystem == 'Ubuntu' and $::lsbdistrelease == '10.04') or ($::operatingsystem == 'SLES') {
    $verify_command = '/usr/sbin/apache2ctl -t'
  } elsif $::operatingsystem == 'FreeBSD' {
    $verify_command = '/usr/local/sbin/apachectl -t'
  } else {
    $verify_command = '/usr/sbin/apachectl -t'
  }
  if $::osfamily == 'RedHat' or $::operatingsystem =~ /^[Aa]mazon$/ {
    $user                 = 'apache'
    $group                = 'apache'
    $root_group           = 'root'
    $apache_name          = 'httpd'
    $service_name         = 'httpd'
    $httpd_dir            = '/etc/httpd'
    $server_root          = '/etc/httpd'
    $conf_dir             = "${httpd_dir}/conf"
    $confd_dir            = "${httpd_dir}/conf.d"
    $mod_dir              = $::apache::version::distrelease ? {
      '7'     => "${httpd_dir}/conf.modules.d",
      default => "${httpd_dir}/conf.d",
    }
    $mod_enable_dir       = undef
    $vhost_dir            = "${httpd_dir}/conf.d"
    $vhost_enable_dir     = undef
    $conf_file            = 'httpd.conf'
    $ports_file           = "${conf_dir}/ports.conf"
    $pidfile              = 'run/httpd.pid'
    $logroot              = '/var/log/httpd'
    $logroot_mode         = undef
    $lib_path             = 'modules'
    $mpm_module           = 'prefork'
    $dev_packages         = 'httpd-devel'
    $default_ssl_cert     = '/etc/pki/tls/certs/localhost.crt'
    $default_ssl_key      = '/etc/pki/tls/private/localhost.key'
    $ssl_certs_dir        = '/etc/pki/tls/certs'
    $ssl_sessioncache     = '/var/cache/mod_ssl/scache(512000)'
    $passenger_conf_file  = 'passenger_extra.conf'
    $passenger_conf_package_file = 'passenger.conf'
    $passenger_root       = undef
    $passenger_ruby       = undef
    $passenger_default_ruby = undef
    $suphp_addhandler     = 'php5-script'
    $suphp_engine         = 'off'
    $suphp_configpath     = undef
    $php_version          = '5'
    $mod_packages         = {
      # NOTE: The auth_cas module isn't available on RH/CentOS without providing dependency packages provided by EPEL.
      'auth_cas'              => 'mod_auth_cas',
      'auth_kerb'             => 'mod_auth_kerb',
      'auth_mellon'           => 'mod_auth_mellon',
      'authnz_ldap'           => $::apache::version::distrelease ? {
        '7'     => 'mod_ldap',
        default => 'mod_authz_ldap',
      },
      'authnz_pam'            => 'mod_authnz_pam',
      'fastcgi'               => 'mod_fastcgi',
      'fcgid'                 => 'mod_fcgid',
      'geoip'                 => 'mod_geoip',
      'intercept_form_submit' => 'mod_intercept_form_submit',
      'ldap'                  => $::apache::version::distrelease ? {
        '7'     => 'mod_ldap',
        default => undef,
      },
      'lookup_identity'       => 'mod_lookup_identity',
      'pagespeed'             => 'mod-pagespeed-stable',
      # NOTE: The passenger module isn't available on RH/CentOS without
      # providing dependency packages provided by EPEL and passenger
      # repositories. See
      # https://www.phusionpassenger.com/library/install/apache/install/oss/el7/
      'passenger'             => 'mod_passenger',
      'perl'                  => 'mod_perl',
      'php5'                  => $::apache::version::distrelease ? {
        '5'     => 'php53',
        default => 'php',
      },
      'phpXXX'                => 'php',
      'proxy_html'            => 'mod_proxy_html',
      'python'                => 'mod_python',
      'security'              => 'mod_security',
      # NOTE: The module for Shibboleth is not available on RH/CentOS without
      # providing dependency packages provided by Shibboleth's repositories.
      # See http://wiki.aaf.edu.au/tech-info/sp-install-guide
      'shibboleth'            => 'shibboleth',
      'ssl'                   => 'mod_ssl',
      'wsgi'                  => 'mod_wsgi',
      'dav_svn'               => 'mod_dav_svn',
      'suphp'                 => 'mod_suphp',
      'xsendfile'             => 'mod_xsendfile',
      'nss'                   => 'mod_nss',
      'shib2'                 => 'shibboleth',
    }
    $mod_libs             = {
      'nss' => 'libmodnss.so',
    }
    $conf_template        = 'apache/httpd.conf.erb'
    $http_protocol_options  = undef
    $keepalive            = 'On'
    $keepalive_timeout    = 15
    $max_keepalive_requests = 100
    $fastcgi_lib_path     = undef
    $mime_support_package = 'mailcap'
    $mime_types_config    = '/etc/mime.types'
    $docroot              = '/var/www/html'
    $alias_icons_path     = $::apache::version::distrelease ? {
      '7'     => '/usr/share/httpd/icons',
      default => '/var/www/icons',
    }
    $error_documents_path = $::apache::version::distrelease ? {
      '7'     => '/usr/share/httpd/error',
      default => '/var/www/error'
    }
    if $::osfamily == 'RedHat' {
      $wsgi_socket_prefix = '/var/run/wsgi'
    } else {
      $wsgi_socket_prefix = undef
    }
    $cas_cookie_path      = '/var/cache/mod_auth_cas/'
    $mellon_lock_file     = '/run/mod_auth_mellon/lock'
    $mellon_cache_size    = 100
    $mellon_post_directory = undef
    $modsec_crs_package   = 'mod_security_crs'
    $modsec_crs_path      = '/usr/lib/modsecurity.d'
    $modsec_dir           = '/etc/httpd/modsecurity.d'
    $secpcrematchlimit = 1500
    $secpcrematchlimitrecursion = 1500
    $modsec_secruleengine = 'On'
    $modsec_default_rules = [
      'base_rules/modsecurity_35_bad_robots.data',
      'base_rules/modsecurity_35_scanners.data',
      'base_rules/modsecurity_40_generic_attacks.data',
      'base_rules/modsecurity_50_outbound.data',
      'base_rules/modsecurity_50_outbound_malware.data',
      'base_rules/modsecurity_crs_20_protocol_violations.conf',
      'base_rules/modsecurity_crs_21_protocol_anomalies.conf',
      'base_rules/modsecurity_crs_23_request_limits.conf',
      'base_rules/modsecurity_crs_30_http_policy.conf',
      'base_rules/modsecurity_crs_35_bad_robots.conf',
      'base_rules/modsecurity_crs_40_generic_attacks.conf',
      'base_rules/modsecurity_crs_41_sql_injection_attacks.conf',
      'base_rules/modsecurity_crs_41_xss_attacks.conf',
      'base_rules/modsecurity_crs_42_tight_security.conf',
      'base_rules/modsecurity_crs_45_trojans.conf',
      'base_rules/modsecurity_crs_47_common_exceptions.conf',
      'base_rules/modsecurity_crs_49_inbound_blocking.conf',
      'base_rules/modsecurity_crs_50_outbound.conf',
      'base_rules/modsecurity_crs_59_outbound_blocking.conf',
      'base_rules/modsecurity_crs_60_correlation.conf',
    ]
    $error_log           = 'error_log'
    $scriptalias         = '/var/www/cgi-bin'
    $access_log_file     = 'access_log'
  } elsif $::osfamily == 'Debian' {
    $user                = 'www-data'
    $group               = 'www-data'
    $root_group          = 'root'
    $apache_name         = 'apache2'
    $service_name        = 'apache2'
    $httpd_dir           = '/etc/apache2'
    $server_root         = '/etc/apache2'
    $conf_dir            = $httpd_dir
    $confd_dir           = "${httpd_dir}/conf.d"
    $mod_dir             = "${httpd_dir}/mods-available"
    $mod_enable_dir      = "${httpd_dir}/mods-enabled"
    $vhost_dir           = "${httpd_dir}/sites-available"
    $vhost_enable_dir    = "${httpd_dir}/sites-enabled"
    $conf_file           = 'apache2.conf'
    $ports_file          = "${conf_dir}/ports.conf"
    $pidfile             = "\${APACHE_PID_FILE}"
    $logroot             = '/var/log/apache2'
    $logroot_mode        = undef
    $lib_path            = '/usr/lib/apache2/modules'
    $mpm_module          = 'prefork'
    $default_ssl_cert    = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    $default_ssl_key     = '/etc/ssl/private/ssl-cert-snakeoil.key'
    $ssl_certs_dir       = '/etc/ssl/certs'
    $ssl_sessioncache    = "\${APACHE_RUN_DIR}/ssl_scache(512000)"
    $suphp_addhandler    = 'x-httpd-php'
    $suphp_engine        = 'off'
    $suphp_configpath    = '/etc/php5/apache2'
    if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '16.04') < 0) or ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '9') < 0) {
      # Only the major version is used here
      $php_version = '5'
      $mod_packages = {
        'auth_cas'              => 'libapache2-mod-auth-cas',
        'auth_kerb'             => 'libapache2-mod-auth-kerb',
        'auth_mellon'           => 'libapache2-mod-auth-mellon',
        'authnz_pam'            => 'libapache2-mod-authnz-pam',
        'dav_svn'               => 'libapache2-svn',
        'fastcgi'               => 'libapache2-mod-fastcgi',
        'fcgid'                 => 'libapache2-mod-fcgid',
        'geoip'                 => 'libapache2-mod-geoip',
        'intercept_form_submit' => 'libapache2-mod-intercept-form-submit',
        'lookup_identity'       => 'libapache2-mod-lookup-identity',
        'nss'                   => 'libapache2-mod-nss',
        'pagespeed'             => 'mod-pagespeed-stable',
        'passenger'             => 'libapache2-mod-passenger',
        'perl'                  => 'libapache2-mod-perl2',
        'phpXXX'                => 'libapache2-mod-phpXXX',
        'proxy_html'            => 'libapache2-mod-proxy-html',
        'python'                => 'libapache2-mod-python',
        'rpaf'                  => 'libapache2-mod-rpaf',
        'security'              => 'libapache2-modsecurity',
        'shib2'                 => 'libapache2-mod-shib2',
        'suphp'                 => 'libapache2-mod-suphp',
        'wsgi'                  => 'libapache2-mod-wsgi',
        'xsendfile'             => 'libapache2-mod-xsendfile',
      }
    } else {
      # major.minor version used since Debian stretch and Ubuntu Xenial
      $php_version = '7.0'
      $mod_packages = {
        'auth_cas'              => 'libapache2-mod-auth-cas',
        'auth_kerb'             => 'libapache2-mod-auth-kerb',
        'auth_mellon'           => 'libapache2-mod-auth-mellon',
        'authnz_pam'            => 'libapache2-mod-authnz-pam',
        'dav_svn'               => 'libapache2-svn',
        'fastcgi'               => 'libapache2-mod-fastcgi',
        'fcgid'                 => 'libapache2-mod-fcgid',
        'geoip'                 => 'libapache2-mod-geoip',
        'intercept_form_submit' => 'libapache2-mod-intercept-form-submit',
        'lookup_identity'       => 'libapache2-mod-lookup-identity',
        'nss'                   => 'libapache2-mod-nss',
        'pagespeed'             => 'mod-pagespeed-stable',
        'passenger'             => 'libapache2-mod-passenger',
        'perl'                  => 'libapache2-mod-perl2',
        'phpXXX'                => 'libapache2-mod-phpXXX',
        'python'                => 'libapache2-mod-python',
        'rpaf'                  => 'libapache2-mod-rpaf',
        'security'              => 'libapache2-modsecurity',
        'shib2'                 => 'libapache2-mod-shib2',
        'suphp'                 => 'libapache2-mod-suphp',
        'wsgi'                  => 'libapache2-mod-wsgi',
        'xsendfile'             => 'libapache2-mod-xsendfile',
      }
    }
    $error_log           = 'error.log'
    $scriptalias         = '/usr/lib/cgi-bin'
    $access_log_file     = 'access.log'
    if $::osfamily == 'Debian' and versioncmp($::operatingsystemrelease, '8') < 0 {
      $shib2_lib = 'mod_shib_22.so'
    } else {
      $shib2_lib = 'mod_shib2.so'
    }
    $mod_libs             = {
      'shib2' => $shib2_lib,
    }
    $conf_template          = 'apache/httpd.conf.erb'
    $http_protocol_options  = undef
    $keepalive              = 'Off'
    $keepalive_timeout      = 15
    $max_keepalive_requests = 100
    $fastcgi_lib_path       = '/var/lib/apache2/fastcgi'
    $mime_support_package = 'mime-support'
    $mime_types_config    = '/etc/mime.types'
    if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '13.10') >= 0) or ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '8') >= 0) {
      $docroot              = '/var/www/html'
    } else {
      $docroot              = '/var/www'
    }
    $cas_cookie_path      = '/var/cache/apache2/mod_auth_cas/'
    $mellon_lock_file     = undef
    $mellon_cache_size    = undef
    $mellon_post_directory = '/var/cache/apache2/mod_auth_mellon/'
    $modsec_crs_package   = 'modsecurity-crs'
    $modsec_crs_path      = '/usr/share/modsecurity-crs'
    $modsec_dir           = '/etc/modsecurity'
    $secpcrematchlimit = 1500
    $secpcrematchlimitrecursion = 1500
    $modsec_secruleengine = 'On'
    $modsec_default_rules = [
      'base_rules/modsecurity_35_bad_robots.data',
      'base_rules/modsecurity_35_scanners.data',
      'base_rules/modsecurity_40_generic_attacks.data',
      'base_rules/modsecurity_50_outbound.data',
      'base_rules/modsecurity_50_outbound_malware.data',
      'base_rules/modsecurity_crs_20_protocol_violations.conf',
      'base_rules/modsecurity_crs_21_protocol_anomalies.conf',
      'base_rules/modsecurity_crs_23_request_limits.conf',
      'base_rules/modsecurity_crs_30_http_policy.conf',
      'base_rules/modsecurity_crs_35_bad_robots.conf',
      'base_rules/modsecurity_crs_40_generic_attacks.conf',
      'base_rules/modsecurity_crs_41_sql_injection_attacks.conf',
      'base_rules/modsecurity_crs_41_xss_attacks.conf',
      'base_rules/modsecurity_crs_42_tight_security.conf',
      'base_rules/modsecurity_crs_45_trojans.conf',
      'base_rules/modsecurity_crs_47_common_exceptions.conf',
      'base_rules/modsecurity_crs_49_inbound_blocking.conf',
      'base_rules/modsecurity_crs_50_outbound.conf',
      'base_rules/modsecurity_crs_59_outbound_blocking.conf',
      'base_rules/modsecurity_crs_60_correlation.conf',
    ]
    $alias_icons_path     = '/usr/share/apache2/icons'
    $error_documents_path = '/usr/share/apache2/error'
    if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '13.10') >= 0) or ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '8') >= 0) {
      $dev_packages        = ['libaprutil1-dev', 'libapr1-dev', 'apache2-dev']
    } else {
      $dev_packages        = ['libaprutil1-dev', 'libapr1-dev', 'apache2-prefork-dev']
    }

    #
    # Passenger-specific settings
    #

    $passenger_conf_file         = 'passenger.conf'
    $passenger_conf_package_file = undef

    if ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '14.04') < 0) or ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '8') < 0) {
      $passenger_root         = '/usr'
      $passenger_ruby         = '/usr/bin/ruby'
      $passenger_default_ruby = undef
    } else {
      $passenger_root         = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
      $passenger_ruby         = undef
      $passenger_default_ruby = '/usr/bin/ruby'
    }
    $wsgi_socket_prefix = undef
  } elsif $::osfamily == 'FreeBSD' {
    $user             = 'www'
    $group            = 'www'
    $root_group       = 'wheel'
    $apache_name      = 'apache24'
    $service_name     = 'apache24'
    $httpd_dir        = '/usr/local/etc/apache24'
    $server_root      = '/usr/local'
    $conf_dir         = $httpd_dir
    $confd_dir        = "${httpd_dir}/Includes"
    $mod_dir          = "${httpd_dir}/Modules"
    $mod_enable_dir   = undef
    $vhost_dir        = "${httpd_dir}/Vhosts"
    $vhost_enable_dir = undef
    $conf_file        = 'httpd.conf'
    $ports_file       = "${conf_dir}/ports.conf"
    $pidfile          = '/var/run/httpd.pid'
    $logroot          = '/var/log/apache24'
    $logroot_mode     = undef
    $lib_path         = '/usr/local/libexec/apache24'
    $mpm_module       = 'prefork'
    $dev_packages     = undef
    $default_ssl_cert = '/usr/local/etc/apache24/server.crt'
    $default_ssl_key  = '/usr/local/etc/apache24/server.key'
    $ssl_certs_dir    = undef
    $ssl_sessioncache  = '/var/run/ssl_scache(512000)'
    $passenger_conf_file = 'passenger.conf'
    $passenger_conf_package_file = undef
    $passenger_root   = '/usr/local/lib/ruby/gems/2.0/gems/passenger-4.0.58'
    $passenger_ruby   = '/usr/local/bin/ruby'
    $passenger_default_ruby = undef
    $suphp_addhandler = 'php5-script'
    $suphp_engine     = 'off'
    $suphp_configpath = undef
    $php_version      = '5'
    $mod_packages     = {
      # NOTE: I list here only modules that are not included in www/apache24
      # NOTE: 'passenger' needs to enable APACHE_SUPPORT in make config
      # NOTE: 'php' needs to enable APACHE option in make config
      # NOTE: 'dav_svn' needs to enable MOD_DAV_SVN make config
      # NOTE: not sure where the shibboleth should come from
      'auth_kerb'  => 'www/mod_auth_kerb2',
      'fcgid'      => 'www/mod_fcgid',
      'passenger'  => 'www/rubygem-passenger',
      'perl'       => 'www/mod_perl2',
      'phpXXX'     => 'www/mod_phpXXX',
      'proxy_html' => 'www/mod_proxy_html',
      'python'     => 'www/mod_python3',
      'wsgi'       => 'www/mod_wsgi',
      'dav_svn'    => 'devel/subversion',
      'xsendfile'  => 'www/mod_xsendfile',
      'rpaf'       => 'www/mod_rpaf2',
      'shib2'      => 'security/shibboleth2-sp',
    }
    $mod_libs         = {
    }
    $conf_template        = 'apache/httpd.conf.erb'
    $http_protocol_options = undef
    $keepalive            = 'Off'
    $keepalive_timeout    = 15
    $max_keepalive_requests = 100
    $fastcgi_lib_path     = undef # TODO: revisit
    $mime_support_package = 'misc/mime-support'
    $mime_types_config    = '/usr/local/etc/mime.types'
    $wsgi_socket_prefix   = undef
    $docroot              = '/usr/local/www/apache24/data'
    $alias_icons_path     = '/usr/local/www/apache24/icons'
    $error_documents_path = '/usr/local/www/apache24/error'
    $error_log            = 'httpd-error.log'
    $scriptalias          = '/usr/local/www/apache24/cgi-bin'
    $access_log_file      = 'httpd-access.log'
  } elsif $::osfamily == 'Gentoo' {
    $user             = 'apache'
    $group            = 'apache'
    $root_group       = 'wheel'
    $apache_name      = 'www-servers/apache'
    $service_name     = 'apache2'
    $httpd_dir        = '/etc/apache2'
    $server_root      = '/var/www'
    $conf_dir         = $httpd_dir
    $confd_dir        = "${httpd_dir}/conf.d"
    $mod_dir          = "${httpd_dir}/modules.d"
    $mod_enable_dir   = undef
    $vhost_dir        = "${httpd_dir}/vhosts.d"
    $vhost_enable_dir = undef
    $conf_file        = 'httpd.conf'
    $ports_file       = "${conf_dir}/ports.conf"
    $logroot          = '/var/log/apache2'
    $logroot_mode     = undef
    $lib_path         = '/usr/lib/apache2/modules'
    $mpm_module       = 'prefork'
    $dev_packages     = undef
    $default_ssl_cert = '/etc/ssl/apache2/server.crt'
    $default_ssl_key  = '/etc/ssl/apache2/server.key'
    $ssl_certs_dir    = '/etc/ssl/apache2'
    $ssl_sessioncache  = '/var/run/ssl_scache(512000)'
    $passenger_root   = '/usr'
    $passenger_ruby   = '/usr/bin/ruby'
    $passenger_conf_file = 'passenger.conf'
    $passenger_conf_package_file = undef
    $passenger_default_ruby = undef
    $suphp_addhandler = 'x-httpd-php'
    $suphp_engine     = 'off'
    $suphp_configpath = '/etc/php5/apache2'
    $php_version      = '5'
    $mod_packages     = {
      # NOTE: I list here only modules that are not included in www-servers/apache
      'auth_kerb'       => 'www-apache/mod_auth_kerb',
      'authnz_external' => 'www-apache/mod_authnz_external',
      'fcgid'           => 'www-apache/mod_fcgid',
      'passenger'       => 'www-apache/passenger',
      'perl'            => 'www-apache/mod_perl',
      'phpXXX'          => 'dev-lang/php',
      'proxy_html'      => 'www-apache/mod_proxy_html',
      'proxy_fcgi'      => 'www-apache/mod_proxy_fcgi',
      'python'          => 'www-apache/mod_python',
      'wsgi'            => 'www-apache/mod_wsgi',
      'dav_svn'         => 'dev-vcs/subversion',
      'xsendfile'       => 'www-apache/mod_xsendfile',
      'rpaf'            => 'www-apache/mod_rpaf',
      'xml2enc'         => 'www-apache/mod_xml2enc',
    }
    $mod_libs         = {
    }
    $conf_template        = 'apache/httpd.conf.erb'
    $http_protocol_options = undef
    $keepalive            = 'Off'
    $keepalive_timeout    = 15
    $max_keepalive_requests = 100
    $fastcgi_lib_path     = undef # TODO: revisit
    $mime_support_package = 'app-misc/mime-types'
    $mime_types_config    = '/etc/mime.types'
    $wsgi_socket_prefix   = undef
    $docroot              = '/var/www/localhost/htdocs'
    $alias_icons_path     = '/usr/share/apache2/icons'
    $error_documents_path = '/usr/share/apache2/error'
    $pidfile              = '/var/run/apache2.pid'
    $error_log            = 'error.log'
    $scriptalias          = '/var/www/localhost/cgi-bin'
    $access_log_file      = 'access.log'
  } elsif $::osfamily == 'Suse' {
    $user                = 'wwwrun'
    $group               = 'www'
    $root_group          = 'root'
    $apache_name         = 'apache2'
    $service_name        = 'apache2'
    $httpd_dir           = '/etc/apache2'
    $server_root         = '/etc/apache2'
    $conf_dir            = $httpd_dir
    $confd_dir           = "${httpd_dir}/conf.d"
    $mod_dir             = "${httpd_dir}/mods-available"
    $mod_enable_dir      = "${httpd_dir}/mods-enabled"
    $vhost_dir           = "${httpd_dir}/sites-available"
    $vhost_enable_dir    = "${httpd_dir}/sites-enabled"
    $conf_file           = 'httpd.conf'
    $ports_file          = "${conf_dir}/ports.conf"
    $pidfile             = '/var/run/httpd2.pid'
    $logroot             = '/var/log/apache2'
    $logroot_mode        = undef
    $lib_path            = '/usr/lib64/apache2' #changes for some modules based on mpm
    $mpm_module          = 'prefork'
    $default_ssl_cert    = '/etc/apache2/ssl.crt/server.crt'
    $default_ssl_key     = '/etc/apache2/ssl.key/server.key'
    $ssl_certs_dir       = '/etc/ssl/certs'
    $ssl_sessioncache    = '/var/lib/apache2/ssl_scache(512000)'
    $suphp_addhandler    = 'x-httpd-php'
    $suphp_engine        = 'off'
    $suphp_configpath    = '/etc/php5/apache2'
    $php_version         = '5'
    if $::operatingsystemrelease < '11' or $::operatingsystemrelease >= '12' {
      $mod_packages      = {
        'auth_kerb'   => 'apache2-mod_auth_kerb',
        'perl'        => 'apache2-mod_perl',
        'php5'        => 'apache2-mod_php5',
        'python'      => 'apache2-mod_python',
        'security'    => 'apache2-mod_security2',
        'worker'      => 'apache2-worker',
        }
    } else {
      $mod_packages        = {
        'auth_kerb'   => 'apache2-mod_auth_kerb',
        'perl'        => 'apache2-mod_perl',
        'php5'        => 'apache2-mod_php53',
        'python'      => 'apache2-mod_python',
        'security'    => 'apache2-mod_security2',
      }
    }
    $mod_libs             = {
      'security'       => '/usr/lib64/apache2/mod_security2.so',
      'php53'          => '/usr/lib64/apache2/mod_php5.so',
    }
    $conf_template          = 'apache/httpd.conf.erb'
    $http_protocol_options  = undef
    $keepalive              = 'Off'
    $keepalive_timeout      = 15
    $max_keepalive_requests = 100
    $fastcgi_lib_path       = '/var/lib/apache2/fastcgi'
    $mime_support_package = 'aaa_base'
    $mime_types_config    = '/etc/mime.types'
    $docroot              = '/srv/www'
    $cas_cookie_path      = '/var/cache/apache2/mod_auth_cas/'
    $mellon_lock_file     = undef
    $mellon_cache_size    = undef
    $mellon_post_directory = undef
    $alias_icons_path     = '/usr/share/apache2/icons'
    $error_documents_path = '/usr/share/apache2/error'
    $dev_packages        = ['libapr-util1-devel', 'libapr1-devel', 'libcurl-devel']
    $modsec_crs_package   = undef
    $modsec_crs_path      = undef
    $modsec_default_rules = undef
    $modsec_dir           = '/etc/apache2/modsecurity'
    $secpcrematchlimit = 1500
    $secpcrematchlimitrecursion = 1500
    $modsec_secruleengine = 'On'
    $error_log           = 'error.log'
    $scriptalias         = '/usr/lib/cgi-bin'
    $access_log_file     = 'access.log'

    #
    # Passenger-specific settings
    #

    $passenger_conf_file          = 'passenger.conf'
    $passenger_conf_package_file  = undef

    $passenger_root               = '/usr/lib64/ruby/gems/1.8/gems/passenger-5.0.30'
    $passenger_ruby               = '/usr/bin/ruby'
    $passenger_default_ruby       = '/usr/bin/ruby'
    $wsgi_socket_prefix           = undef

  } else {
    fail("Class['apache::params']: Unsupported osfamily: ${::osfamily}")
  }
}
