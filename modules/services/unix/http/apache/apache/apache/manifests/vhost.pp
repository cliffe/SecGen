# See README.md for usage information
define apache::vhost(
  $docroot,
  $manage_docroot              = true,
  $virtual_docroot             = false,
  $port                        = undef,
  $ip                          = undef,
  $ip_based                    = false,
  $add_listen                  = true,
  $docroot_owner               = 'root',
  $docroot_group               = $::apache::params::root_group,
  $docroot_mode                = undef,
  $serveradmin                 = undef,
  $ssl                         = false,
  $ssl_cert                    = $::apache::default_ssl_cert,
  $ssl_key                     = $::apache::default_ssl_key,
  $ssl_chain                   = $::apache::default_ssl_chain,
  $ssl_ca                      = $::apache::default_ssl_ca,
  $ssl_crl_path                = $::apache::default_ssl_crl_path,
  $ssl_crl                     = $::apache::default_ssl_crl,
  $ssl_crl_check               = $::apache::default_ssl_crl_check,
  $ssl_certs_dir               = $::apache::params::ssl_certs_dir,
  $ssl_protocol                = undef,
  $ssl_cipher                  = undef,
  $ssl_honorcipherorder        = undef,
  $ssl_verify_client           = undef,
  $ssl_verify_depth            = undef,
  $ssl_proxy_verify            = undef,
  $ssl_proxy_check_peer_cn     = undef,
  $ssl_proxy_check_peer_name   = undef,
  $ssl_proxy_machine_cert      = undef,
  $ssl_options                 = undef,
  $ssl_openssl_conf_cmd        = undef,
  $ssl_proxyengine             = false,
  $priority                    = undef,
  $default_vhost               = false,
  $servername                  = $name,
  $serveraliases               = [],
  $options                     = ['Indexes','FollowSymLinks','MultiViews'],
  $override                    = ['None'],
  $directoryindex              = '',
  $vhost_name                  = '*',
  $logroot                     = $::apache::logroot,
  $logroot_ensure              = 'directory',
  $logroot_mode                = undef,
  $log_level                   = undef,
  $access_log                  = true,
  $access_log_file             = false,
  $access_log_pipe             = false,
  $access_log_syslog           = false,
  $access_log_format           = false,
  $access_log_env_var          = false,
  $access_logs                 = undef,
  $aliases                     = undef,
  $directories                 = undef,
  $error_log                   = true,
  $error_log_file              = undef,
  $error_log_pipe              = undef,
  $error_log_syslog            = undef,
  $error_documents             = [],
  $fallbackresource            = undef,
  $scriptalias                 = undef,
  $scriptaliases               = [],
  $proxy_dest                  = undef,
  $proxy_dest_match            = undef,
  $proxy_dest_reverse_match    = undef,
  $proxy_pass                  = undef,
  $proxy_pass_match            = undef,
  $suphp_addhandler            = $::apache::params::suphp_addhandler,
  $suphp_engine                = $::apache::params::suphp_engine,
  $suphp_configpath            = $::apache::params::suphp_configpath,
  $php_flags                   = {},
  $php_values                  = {},
  $php_admin_flags             = {},
  $php_admin_values            = {},
  $no_proxy_uris               = [],
  $no_proxy_uris_match         = [],
  $proxy_preserve_host         = false,
  $proxy_error_override        = false,
  $redirect_source             = '/',
  $redirect_dest               = undef,
  $redirect_status             = undef,
  $redirectmatch_status        = undef,
  $redirectmatch_regexp        = undef,
  $redirectmatch_dest          = undef,
  $rack_base_uris              = undef,
  $passenger_base_uris         = undef,
  $headers                     = undef,
  $request_headers             = undef,
  $filters                     = undef,
  $rewrites                    = undef,
  $rewrite_base                = undef,
  $rewrite_rule                = undef,
  $rewrite_cond                = undef,
  $setenv                      = [],
  $setenvif                    = [],
  $block                       = [],
  $ensure                      = 'present',
  $wsgi_application_group      = undef,
  $wsgi_daemon_process         = undef,
  $wsgi_daemon_process_options = undef,
  $wsgi_import_script          = undef,
  $wsgi_import_script_options  = undef,
  $wsgi_process_group          = undef,
  $wsgi_script_aliases         = undef,
  $wsgi_pass_authorization     = undef,
  $wsgi_chunked_request        = undef,
  $custom_fragment             = undef,
  $itk                         = undef,
  $action                      = undef,
  $fastcgi_server              = undef,
  $fastcgi_socket              = undef,
  $fastcgi_dir                 = undef,
  $additional_includes         = [],
  $use_optional_includes       = $::apache::use_optional_includes,
  $apache_version              = $::apache::apache_version,
  $allow_encoded_slashes       = undef,
  $suexec_user_group           = undef,
  $passenger_app_root          = undef,
  $passenger_app_env           = undef,
  $passenger_ruby              = undef,
  $passenger_min_instances     = undef,
  $passenger_start_timeout     = undef,
  $passenger_pre_start         = undef,
  $add_default_charset         = undef,
  $modsec_disable_vhost        = undef,
  $modsec_disable_ids          = undef,
  $modsec_disable_ips          = undef,
  $modsec_body_limit           = undef,
  $auth_kerb                   = false,
  $krb_method_negotiate        = 'on',
  $krb_method_k5passwd         = 'on',
  $krb_authoritative           = 'on',
  $krb_auth_realms             = [],
  $krb_5keytab                 = undef,
  $krb_local_user_mapping      = undef,
  $krb_verify_kdc              = 'on',
  $krb_servicename             = 'HTTP',
  $krb_save_credentials        = 'off',
) {
  # The base class must be included first because it is used by parameter defaults
  if ! defined(Class['apache']) {
    fail('You must include the apache base class before using any apache defined resources')
  }

  $apache_name = $::apache::apache_name

  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure.
  Allowed values are 'present' and 'absent'.")
  validate_re($suphp_engine, '^(on|off)$',
  "${suphp_engine} is not supported for suphp_engine.
  Allowed values are 'on' and 'off'.")
  validate_bool($ip_based)
  validate_bool($access_log)
  validate_bool($error_log)
  validate_bool($ssl)
  validate_bool($default_vhost)
  validate_bool($ssl_proxyengine)
  if $rewrites {
    validate_array($rewrites)
    unless empty($rewrites) {
      validate_hash($rewrites[0])
    }
  }

  # Input validation begins

  if $suexec_user_group {
    validate_re($suexec_user_group, '^[\w-]+ [\w-]+$',
    "${suexec_user_group} is not supported for suexec_user_group.  Must be 'user group'.")
  }

  if $wsgi_pass_authorization {
    validate_re(downcase($wsgi_pass_authorization), '^(on|off)$',
    "${wsgi_pass_authorization} is not supported for wsgi_pass_authorization.
    Allowed values are 'on' and 'off'.")
  }

  # Deprecated backwards-compatibility
  if $rewrite_base {
    warning('Apache::Vhost: parameter rewrite_base is deprecated in favor of rewrites')
  }
  if $rewrite_rule {
    warning('Apache::Vhost: parameter rewrite_rule is deprecated in favor of rewrites')
  }
  if $rewrite_cond {
    warning('Apache::Vhost parameter rewrite_cond is deprecated in favor of rewrites')
  }

  if $wsgi_script_aliases {
    validate_hash($wsgi_script_aliases)
  }
  if $wsgi_daemon_process_options {
    validate_hash($wsgi_daemon_process_options)
  }
  if $wsgi_import_script_options {
    validate_hash($wsgi_import_script_options)
  }
  if $itk {
    validate_hash($itk)
  }

  validate_re($logroot_ensure, '^(directory|absent)$',
  "${logroot_ensure} is not supported for logroot_ensure.
  Allowed values are 'directory' and 'absent'.")

  if $log_level {
    validate_apache_log_level($log_level)
  }

  if $access_log_file and $access_log_pipe {
    fail("Apache::Vhost[${name}]: 'access_log_file' and 'access_log_pipe' cannot be defined at the same time")
  }

  if $error_log_file and $error_log_pipe {
    fail("Apache::Vhost[${name}]: 'error_log_file' and 'error_log_pipe' cannot be defined at the same time")
  }

  if $fallbackresource {
    validate_re($fallbackresource, '^/|disabled', 'Please make sure fallbackresource starts with a / (or is "disabled")')
  }

  if $custom_fragment {
    validate_string($custom_fragment)
  }

  if $allow_encoded_slashes {
    validate_re($allow_encoded_slashes, '(^on$|^off$|^nodecode$)', "${allow_encoded_slashes} is not permitted for allow_encoded_slashes. Allowed values are 'on', 'off' or 'nodecode'.")
  }

  validate_bool($auth_kerb)

  # Validate the docroot as a string if:
  # - $manage_docroot is true
  if $manage_docroot {
    validate_string($docroot)
  }

  if $ssl_proxy_verify {
    validate_re($ssl_proxy_verify,'^(none|optional|require|optional_no_ca)$',"${ssl_proxy_verify} is not permitted for ssl_proxy_verify. Allowed values are 'none', 'optional', 'require' or 'optional_no_ca'.")
  }

  if $ssl_proxy_check_peer_cn {
    validate_re($ssl_proxy_check_peer_cn,'(^on$|^off$)',"${ssl_proxy_check_peer_cn} is not permitted for ssl_proxy_check_peer_cn. Allowed values are 'on' or 'off'.")
  }
  if $ssl_proxy_check_peer_name {
    validate_re($ssl_proxy_check_peer_name,'(^on$|^off$)',"${ssl_proxy_check_peer_name} is not permitted for ssl_proxy_check_peer_name. Allowed values are 'on' or 'off'.")
  }

  # Input validation ends

  if $ssl and $ensure == 'present' {
    include ::apache::mod::ssl
    # Required for the AddType lines.
    include ::apache::mod::mime
  }

  if $auth_kerb and $ensure == 'present' {
    include ::apache::mod::auth_kerb
  }

  if $virtual_docroot {
    include ::apache::mod::vhost_alias
  }

  if $wsgi_daemon_process {
    include ::apache::mod::wsgi
  }

  if $suexec_user_group {
    include ::apache::mod::suexec
  }

  if $passenger_app_root or $passenger_app_env or $passenger_ruby or $passenger_min_instances or $passenger_start_timeout or $passenger_pre_start {
    include ::apache::mod::passenger
  }

  # Configure the defaultness of a vhost
  if $priority {
    $priority_real = "${priority}-"
  } elsif $priority == false {
    $priority_real = ''
  } elsif $default_vhost {
    $priority_real = '10-'
  } else {
    $priority_real = '25-'
  }

  ## Apache include does not always work with spaces in the filename
  $filename = regsubst($name, ' ', '_', 'G')

  # This ensures that the docroot exists
  # But enables it to be specified across multiple vhost resources
  if $manage_docroot and $docroot and ! defined(File[$docroot]) {
    file { $docroot:
      ensure  => directory,
      owner   => $docroot_owner,
      group   => $docroot_group,
      mode    => $docroot_mode,
      require => Package['httpd'],
      before  => Concat["${priority_real}${filename}.conf"],
    }
  }

  # Same as above, but for logroot
  if ! defined(File[$logroot]) {
    file { $logroot:
      ensure  => $logroot_ensure,
      mode    => $logroot_mode,
      require => Package['httpd'],
      before  => Concat["${priority_real}${filename}.conf"],
    }
  }


  # Is apache::mod::passenger enabled (or apache::mod['passenger'])
  $passenger_enabled = defined(Apache::Mod['passenger'])

  # Is apache::mod::shib enabled (or apache::mod['shib2'])
  $shibboleth_enabled = defined(Apache::Mod['shib2'])

  if $access_log and !$access_logs {
    if $access_log_file {
      $_logs_dest = "${logroot}/${access_log_file}"
    } elsif $access_log_pipe {
      $_logs_dest = $access_log_pipe
    } elsif $access_log_syslog {
      $_logs_dest = $access_log_syslog
    } else {
      $_logs_dest = undef
    }
    $_access_logs = [{
      'file'        => $access_log_file,
      'pipe'        => $access_log_pipe,
      'syslog'      => $access_log_syslog,
      'format'      => $access_log_format,
      'env'         => $access_log_env_var
    }]
  } elsif $access_logs {
    if !is_array($access_logs) {
      fail("Apache::Vhost[${name}]: access_logs must be an array of hashes")
    }
    $_access_logs = $access_logs
  }

  if $error_log_file {
    $error_log_destination = "${logroot}/${error_log_file}"
  } elsif $error_log_pipe {
    $error_log_destination = $error_log_pipe
  } elsif $error_log_syslog {
    $error_log_destination = $error_log_syslog
  } else {
    if $ssl {
      $error_log_destination = "${logroot}/${name}_error_ssl.log"
    } else {
      $error_log_destination = "${logroot}/${name}_error.log"
    }
  }

  if $ip {
    $_ip = enclose_ipv6($ip)
    if $port {
      $listen_addr_port = suffix(any2array($_ip),":${port}")
      $nvh_addr_port = suffix(any2array($_ip),":${port}")
    } else {
      $listen_addr_port = undef
      $nvh_addr_port = $_ip
      if ! $servername and ! $ip_based {
        fail("Apache::Vhost[${name}]: must pass 'ip' and/or 'port' parameters for name-based vhosts")
      }
    }
  } else {
    if $port {
      $listen_addr_port = $port
      $nvh_addr_port = "${vhost_name}:${port}"
    } else {
      $listen_addr_port = undef
      $nvh_addr_port = $name
      if ! $servername {
        fail("Apache::Vhost[${name}]: must pass 'ip' and/or 'port' parameters, and/or 'servername' parameter")
      }
    }
  }
  if $add_listen {
    if $ip and defined(Apache::Listen["${port}"]) {
      fail("Apache::Vhost[${name}]: Mixing IP and non-IP Listen directives is not possible; check the add_listen parameter of the apache::vhost define to disable this")
    }
    if $listen_addr_port and $ensure == 'present' {
      ensure_resource('apache::listen', $listen_addr_port)
    }
  }
  if ! $ip_based {
    if $ensure == 'present' and (versioncmp($apache_version, '2.4') < 0) {
      ensure_resource('apache::namevirtualhost', $nvh_addr_port)
    }
  }

  # Load mod_rewrite if needed and not yet loaded
  if $rewrites or $rewrite_cond {
    if ! defined(Class['apache::mod::rewrite']) {
      include ::apache::mod::rewrite
    }
  }

  # Load mod_alias if needed and not yet loaded
  if ($scriptalias or $scriptaliases != []) or ($aliases and $aliases != []) or ($redirect_source and $redirect_dest) {
    if ! defined(Class['apache::mod::alias'])  and ($ensure == 'present') {
      include ::apache::mod::alias
    }
  }

  # Load mod_proxy if needed and not yet loaded
  if ($proxy_dest or $proxy_pass or $proxy_pass_match or $proxy_dest_match) {
    if ! defined(Class['apache::mod::proxy']) {
      include ::apache::mod::proxy
    }
    if ! defined(Class['apache::mod::proxy_http']) {
      include ::apache::mod::proxy_http
    }
  }

  # Load mod_passenger if needed and not yet loaded
  if $rack_base_uris {
    if ! defined(Class['apache::mod::passenger']) {
      include ::apache::mod::passenger
    }
  }

  # Load mod_passenger if needed and not yet loaded
  if $passenger_base_uris {
      include ::apache::mod::passenger
  }

  # Load mod_fastci if needed and not yet loaded
  if $fastcgi_server and $fastcgi_socket {
    if ! defined(Class['apache::mod::fastcgi']) {
      include ::apache::mod::fastcgi
    }
  }

  # Check if mod_headers is required to process $headers/$request_headers
  if $headers or $request_headers {
    if ! defined(Class['apache::mod::headers']) {
      include ::apache::mod::headers
    }
  }

  # Check if mod_filter is required to process $filters
  if $filters {
    if ! defined(Class['apache::mod::filter']) {
      include ::apache::mod::filter
    }
  }

  if ($setenv and ! empty($setenv)) or ($setenvif and ! empty($setenvif)) {
    if ! defined(Class['apache::mod::setenvif']) {
      include ::apache::mod::setenvif
    }
  }

  ## Create a default directory list if none defined
  if $directories {
    if !is_hash($directories) and !(is_array($directories) and is_hash($directories[0])) {
      fail("Apache::Vhost[${name}]: 'directories' must be either a Hash or an Array of Hashes")
    }
    $_directories = $directories
  } elsif $docroot {
    $_directory = {
      provider       => 'directory',
      path           => $docroot,
      options        => $options,
      allow_override => $override,
      directoryindex => $directoryindex,
    }

    if versioncmp($apache_version, '2.4') >= 0 {
      $_directory_version = {
        require => 'all granted',
      }
    } else {
      $_directory_version = {
        order => 'allow,deny',
        allow => 'from all',
      }
    }

    $_directories = [ merge($_directory, $_directory_version) ]
  }

  ## Create a global LocationMatch if locations aren't defined
  if $modsec_disable_ids {
    if is_hash($modsec_disable_ids) {
      $_modsec_disable_ids = $modsec_disable_ids
    } elsif is_array($modsec_disable_ids) {
      $_modsec_disable_ids = { '.*' => $modsec_disable_ids }
    } else {
      fail("Apache::Vhost[${name}]: 'modsec_disable_ids' must be either a Hash of location/IDs or an Array of IDs")
    }
  }

  concat { "${priority_real}${filename}.conf":
    ensure  => $ensure,
    path    => "${::apache::vhost_dir}/${priority_real}${filename}.conf",
    owner   => 'root',
    group   => $::apache::params::root_group,
    mode    => $::apache::file_mode,
    order   => 'numeric',
    require => Package['httpd'],
    notify  => Class['apache::service'],
  }
  # NOTE(pabelanger): This code is duplicated in ::apache::vhost::custom and
  # needs to be converted into something generic.
  if $::apache::vhost_enable_dir {
    $vhost_enable_dir = $::apache::vhost_enable_dir
    $vhost_symlink_ensure = $ensure ? {
      present => link,
      default => $ensure,
    }
    file{ "${priority_real}${filename}.conf symlink":
      ensure  => $vhost_symlink_ensure,
      path    => "${vhost_enable_dir}/${priority_real}${filename}.conf",
      target  => "${::apache::vhost_dir}/${priority_real}${filename}.conf",
      owner   => 'root',
      group   => $::apache::params::root_group,
      mode    => $::apache::file_mode,
      require => Concat["${priority_real}${filename}.conf"],
      notify  => Class['apache::service'],
    }
  }

  # Template uses:
  # - $nvh_addr_port
  # - $servername
  # - $serveradmin
  concat::fragment { "${name}-apache-header":
    target  => "${priority_real}${filename}.conf",
    order   => 0,
    content => template('apache/vhost/_file_header.erb'),
  }

  # Template uses:
  # - $virtual_docroot
  # - $docroot
  if $docroot {
    concat::fragment { "${name}-docroot":
      target  => "${priority_real}${filename}.conf",
      order   => 10,
      content => template('apache/vhost/_docroot.erb'),
    }
  }

  # Template uses:
  # - $aliases
  if $aliases and ! empty($aliases) {
    concat::fragment { "${name}-aliases":
      target  => "${priority_real}${filename}.conf",
      order   => 20,
      content => template('apache/vhost/_aliases.erb'),
    }
  }

  # Template uses:
  # - $itk
  # - $::kernelversion
  if $itk and ! empty($itk) {
    concat::fragment { "${name}-itk":
      target  => "${priority_real}${filename}.conf",
      order   => 30,
      content => template('apache/vhost/_itk.erb'),
    }
  }

  # Template uses:
  # - $fallbackresource
  if $fallbackresource {
    concat::fragment { "${name}-fallbackresource":
      target  => "${priority_real}${filename}.conf",
      order   => 40,
      content => template('apache/vhost/_fallbackresource.erb'),
    }
  }

  # Template uses:
  # - $allow_encoded_slashes
  if $allow_encoded_slashes {
    concat::fragment { "${name}-allow_encoded_slashes":
      target  => "${priority_real}${filename}.conf",
      order   => 50,
      content => template('apache/vhost/_allow_encoded_slashes.erb'),
    }
  }

  # Template uses:
  # - $_directories
  # - $docroot
  # - $apache_version
  # - $suphp_engine
  # - $shibboleth_enabled
  if $_directories and ! empty($_directories) {
    concat::fragment { "${name}-directories":
      target  => "${priority_real}${filename}.conf",
      order   => 60,
      content => template('apache/vhost/_directories.erb'),
    }
  }

  # Template uses:
  # - $additional_includes
  if $additional_includes and ! empty($additional_includes) {
    concat::fragment { "${name}-additional_includes":
      target  => "${priority_real}${filename}.conf",
      order   => 70,
      content => template('apache/vhost/_additional_includes.erb'),
    }
  }

  # Template uses:
  # - $error_log
  # - $log_level
  # - $error_log_destination
  # - $log_level
  if $error_log or $log_level {
    concat::fragment { "${name}-logging":
      target  => "${priority_real}${filename}.conf",
      order   => 80,
      content => template('apache/vhost/_logging.erb'),
    }
  }

  # Template uses no variables
  concat::fragment { "${name}-serversignature":
    target  => "${priority_real}${filename}.conf",
    order   => 90,
    content => template('apache/vhost/_serversignature.erb'),
  }

  # Template uses:
  # - $access_log
  # - $_access_log_env_var
  # - $access_log_destination
  # - $_access_log_format
  # - $_access_log_env_var
  # - $access_logs
  if $access_log or $access_logs {
    concat::fragment { "${name}-access_log":
      target  => "${priority_real}${filename}.conf",
      order   => 100,
      content => template('apache/vhost/_access_log.erb'),
    }
  }

  # Template uses:
  # - $action
  if $action {
    concat::fragment { "${name}-action":
      target  => "${priority_real}${filename}.conf",
      order   => 110,
      content => template('apache/vhost/_action.erb'),
    }
  }

  # Template uses:
  # - $block
  # - $apache_version
  if $block and ! empty($block) {
    concat::fragment { "${name}-block":
      target  => "${priority_real}${filename}.conf",
      order   => 120,
      content => template('apache/vhost/_block.erb'),
    }
  }

  # Template uses:
  # - $error_documents
  if $error_documents and ! empty($error_documents) {
    concat::fragment { "${name}-error_document":
      target  => "${priority_real}${filename}.conf",
      order   => 130,
      content => template('apache/vhost/_error_document.erb'),
    }
  }

  # Template uses:
  # - $headers
  if $headers and ! empty($headers) {
    concat::fragment { "${name}-header":
      target  => "${priority_real}${filename}.conf",
      order   => 140,
      content => template('apache/vhost/_header.erb'),
    }
  }

  # Template uses:
  # - $request_headers
  if $request_headers and ! empty($request_headers) {
    concat::fragment { "${name}-requestheader":
      target  => "${priority_real}${filename}.conf",
      order   => 150,
      content => template('apache/vhost/_requestheader.erb'),
    }
  }

  # Template uses:
  # - $proxy_dest
  # - $proxy_pass
  # - $proxy_pass_match
  # - $proxy_preserve_host
  # - $no_proxy_uris
  if $proxy_dest or $proxy_pass or $proxy_pass_match or $proxy_dest_match {
    concat::fragment { "${name}-proxy":
      target  => "${priority_real}${filename}.conf",
      order   => 160,
      content => template('apache/vhost/_proxy.erb'),
    }
  }

  # Template uses:
  # - $rack_base_uris
  if $rack_base_uris {
    concat::fragment { "${name}-rack":
      target  => "${priority_real}${filename}.conf",
      order   => 170,
      content => template('apache/vhost/_rack.erb'),
    }
  }

  # Template uses:
  # - $passenger_base_uris
  if $passenger_base_uris {
    concat::fragment { "${name}-passenger_uris":
      target  => "${priority_real}${filename}.conf",
      order   => 175,
      content => template('apache/vhost/_passenger_base_uris.erb'),
    }
  }

  # Template uses:
  # - $redirect_source
  # - $redirect_dest
  # - $redirect_status
  # - $redirect_dest_a
  # - $redirect_source_a
  # - $redirect_status_a
  # - $redirectmatch_status
  # - $redirectmatch_regexp
  # - $redirectmatch_dest
  # - $redirectmatch_status_a
  # - $redirectmatch_regexp_a
  # - $redirectmatch_dest
  if ($redirect_source and $redirect_dest) or ($redirectmatch_status and $redirectmatch_regexp and $redirectmatch_dest) {
    concat::fragment { "${name}-redirect":
      target  => "${priority_real}${filename}.conf",
      order   => 180,
      content => template('apache/vhost/_redirect.erb'),
    }
  }

  # Template uses:
  # - $rewrites
  # - $rewrite_base
  # - $rewrite_rule
  # - $rewrite_cond
  # - $rewrite_map
  if $rewrites or $rewrite_rule {
    concat::fragment { "${name}-rewrite":
      target  => "${priority_real}${filename}.conf",
      order   => 190,
      content => template('apache/vhost/_rewrite.erb'),
    }
  }

  # Template uses:
  # - $scriptaliases
  # - $scriptalias
  if ( $scriptalias or $scriptaliases != [] ) {
    concat::fragment { "${name}-scriptalias":
      target  => "${priority_real}${filename}.conf",
      order   => 200,
      content => template('apache/vhost/_scriptalias.erb'),
    }
  }

  # Template uses:
  # - $serveraliases
  if $serveraliases and ! empty($serveraliases) {
    concat::fragment { "${name}-serveralias":
      target  => "${priority_real}${filename}.conf",
      order   => 210,
      content => template('apache/vhost/_serveralias.erb'),
    }
  }

  # Template uses:
  # - $setenv
  # - $setenvif
  if ($setenv and ! empty($setenv)) or ($setenvif and ! empty($setenvif)) {
    concat::fragment { "${name}-setenv":
      target  => "${priority_real}${filename}.conf",
      order   => 220,
      content => template('apache/vhost/_setenv.erb'),
    }
  }

  # Template uses:
  # - $ssl
  # - $ssl_cert
  # - $ssl_key
  # - $ssl_chain
  # - $ssl_certs_dir
  # - $ssl_ca
  # - $ssl_crl_path
  # - $ssl_crl
  # - $ssl_crl_check
  # - $ssl_protocol
  # - $ssl_cipher
  # - $ssl_honorcipherorder
  # - $ssl_verify_client
  # - $ssl_verify_depth
  # - $ssl_options
  # - $ssl_openssl_conf_cmd
  # - $apache_version
  if $ssl {
    concat::fragment { "${name}-ssl":
      target  => "${priority_real}${filename}.conf",
      order   => 230,
      content => template('apache/vhost/_ssl.erb'),
    }
  }

  # Template uses:
  # - $ssl_proxyengine
  # - $ssl_proxy_verify
  # - $ssl_proxy_check_peer_cn
  # - $ssl_proxy_check_peer_name
  # - $ssl_proxy_machine_cert
  if $ssl_proxyengine {
    concat::fragment { "${name}-sslproxy":
      target  => "${priority_real}${filename}.conf",
      order   => 230,
      content => template('apache/vhost/_sslproxy.erb'),
    }
  }

  # Template uses:
  # - $auth_kerb
  # - $krb_method_negotiate
  # - $krb_method_k5passwd
  # - $krb_authoritative
  # - $krb_auth_realms
  # - $krb_5keytab
  # - $krb_local_user_mapping
  if $auth_kerb {
    concat::fragment { "${name}-auth_kerb":
      target  => "${priority_real}${filename}.conf",
      order   => 230,
      content => template('apache/vhost/_auth_kerb.erb'),
    }
  }

  # Template uses:
  # - $suphp_engine
  # - $suphp_addhandler
  # - $suphp_configpath
  if $suphp_engine == 'on' {
    concat::fragment { "${name}-suphp":
      target  => "${priority_real}${filename}.conf",
      order   => 240,
      content => template('apache/vhost/_suphp.erb'),
    }
  }

  # Template uses:
  # - $php_values
  # - $php_flags
  if ($php_values and ! empty($php_values)) or ($php_flags and ! empty($php_flags)) {
    concat::fragment { "${name}-php":
      target  => "${priority_real}${filename}.conf",
      order   => 240,
      content => template('apache/vhost/_php.erb'),
    }
  }

  # Template uses:
  # - $php_admin_values
  # - $php_admin_flags
  if ($php_admin_values and ! empty($php_admin_values)) or ($php_admin_flags and ! empty($php_admin_flags)) {
    concat::fragment { "${name}-php_admin":
      target  => "${priority_real}${filename}.conf",
      order   => 250,
      content => template('apache/vhost/_php_admin.erb'),
    }
  }

  # Template uses:
  # - $wsgi_application_group
  # - $wsgi_daemon_process
  # - $wsgi_daemon_process_options
  # - $wsgi_import_script
  # - $wsgi_import_script_options
  # - $wsgi_process_group
  # - $wsgi_script_aliases
  # - $wsgi_pass_authorization
  if $wsgi_application_group or $wsgi_daemon_process or ($wsgi_import_script and $wsgi_import_script_options) or $wsgi_process_group or ($wsgi_script_aliases and ! empty($wsgi_script_aliases)) or $wsgi_pass_authorization {
    concat::fragment { "${name}-wsgi":
      target  => "${priority_real}${filename}.conf",
      order   => 260,
      content => template('apache/vhost/_wsgi.erb'),
    }
  }

  # Template uses:
  # - $custom_fragment
  if $custom_fragment {
    concat::fragment { "${name}-custom_fragment":
      target  => "${priority_real}${filename}.conf",
      order   => 270,
      content => template('apache/vhost/_custom_fragment.erb'),
    }
  }

  # Template uses:
  # - $fastcgi_server
  # - $fastcgi_socket
  # - $fastcgi_dir
  # - $apache_version
  if $fastcgi_server or $fastcgi_dir {
    concat::fragment { "${name}-fastcgi":
      target  => "${priority_real}${filename}.conf",
      order   => 280,
      content => template('apache/vhost/_fastcgi.erb'),
    }
  }

  # Template uses:
  # - $suexec_user_group
  if $suexec_user_group {
    concat::fragment { "${name}-suexec":
      target  => "${priority_real}${filename}.conf",
      order   => 290,
      content => template('apache/vhost/_suexec.erb'),
    }
  }

  # Template uses:
  # - $passenger_app_root
  # - $passenger_app_env
  # - $passenger_ruby
  # - $passenger_min_instances
  # - $passenger_start_timeout
  # - $passenger_pre_start
  if $passenger_app_root or $passenger_app_env or $passenger_ruby or $passenger_min_instances or $passenger_start_timeout or $passenger_pre_start {
    concat::fragment { "${name}-passenger":
      target  => "${priority_real}${filename}.conf",
      order   => 300,
      content => template('apache/vhost/_passenger.erb'),
    }
  }

  # Template uses:
  # - $add_default_charset
  if $add_default_charset {
    concat::fragment { "${name}-charsets":
      target  => "${priority_real}${filename}.conf",
      order   => 310,
      content => template('apache/vhost/_charsets.erb'),
    }
  }

  # Template uses:
  # - $modsec_disable_vhost
  # - $modsec_disable_ids
  # - $modsec_disable_ips
  # - $modsec_body_limit
  if $modsec_disable_vhost or $modsec_disable_ids or $modsec_disable_ips {
    concat::fragment { "${name}-security":
      target  => "${priority_real}${filename}.conf",
      order   => 320,
      content => template('apache/vhost/_security.erb')
    }
  }

  # Template uses:
  # - $filters
  if $filters and ! empty($filters) {
    concat::fragment { "${name}-filters":
      target  => "${priority_real}${filename}.conf",
      order   => 330,
      content => template('apache/vhost/_filters.erb'),
    }
  }

  # Template uses no variables
  concat::fragment { "${name}-file_footer":
    target  => "${priority_real}${filename}.conf",
    order   => 999,
    content => template('apache/vhost/_file_footer.erb'),
  }
}
