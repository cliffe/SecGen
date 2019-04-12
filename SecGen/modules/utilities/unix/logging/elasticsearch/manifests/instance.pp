#  This define allows you to create or remove an elasticsearch instance
#
# @param ensure
#   Controls if the managed resources shall be `present` or `absent`.
#   If set to `absent`, the managed software packages will be uninstalled, and
#   any traces of the packages will be purged as well as possible, possibly
#   including existing configuration files.
#   System modifications (if any) will be reverted as well as possible (e.g.
#   removal of created users, services, changed log settings, and so on).
#   This is a destructive parameter and should be used with care.
#
# @param ca_certificate
#   Path to the trusted CA certificate to add to this node's java keystore.
#
# @param certificate
#   Path to the certificate for this node signed by the CA listed in
#   ca_certificate.
#
# @param config
#   Elasticsearch configuration hash.
#
# @param configdir
#   Path to directory containing the elasticsearch configuration.
#   Use this setting if your packages deviate from the norm (/etc/elasticsearch).
#
# @param daily_rolling_date_pattern
#   File pattern for the file appender log when file_rolling_type is `dailyRollingFile`
#
# @param datadir
#   Allows you to set the data directory of Elasticsearch
#
# @param datadir_instance_directories
#   Control whether individual directories for instances will be created within
#   each instance's data directory.
#
# @param deprecation_logging
#   Wheter to enable deprecation logging. If enabled, deprecation logs will be
#   saved to ${cluster.name}_deprecation.log in the elastic search log folder.
#
# @param deprecation_logging_level
#   Default deprecation logging level for Elasticsearch.
#
# @param file_rolling_type
#   Configuration for the file appender rotation. It can be `dailyRollingFile`
#   or `rollingFile`. The first rotates by name, and the second one by size.
#
# @param init_defaults
#   Defaults file content in hash representation.
#
# @param init_defaults_file
#   Defaults file as puppet resource.
#
# @param init_template
#   Service file as a template
#
# @param jvm_options
#   Array of options to set in jvm_options.
#
# @param keystore_password
#   Password to encrypt this node's Java keystore.
#
# @param keystore_path
#   Custom path to the java keystore file. This parameter is optional.
#
# @param logdir
#   Log directory for this instance.
#
# @param logging_config
#   Hash representation of information you want in the logging.yml file.
#
# @param logging_file
#   Instead of a hash you can supply a puppet:// file source for the logging.yml file
#
# @param logging_level
#   Default logging level for Elasticsearch.
#
# @param logging_template
#  Use a custom logging template - just supply the reative path, ie
#  $module_name/elasticsearch/logging.yml.erb
#
# @param private_key
#   Path to the key associated with this node's certificate.
#
# @param purge_secrets
#   Whether or not keys present in the keystore will be removed if they are not
#   present in the specified secrets hash.
#
# @param rolling_file_max_backup_index
#   Max number of logs to store whern file_rolling_type is `rollingFile`
#
# @param rolling_file_max_file_size
#   Max log file size when file_rolling_type is `rollingFile`
#
# @param secrets
#   Optional configuration hash of key/value pairs to store in the instance's
#   Elasticsearch keystore file. If unset, the keystore is left unmanaged.
#
# @param security_plugin
#   Which security plugin will be used to manage users, roles, and
#   certificates. Inherited from top-level Elasticsearch class.
#
# @param service_flags
#   Service flags used for the OpenBSD service configuration, defaults to undef.
#
# @param ssl
#   Whether to manage TLS certificates for Shield. Requires the ca_certificate,
#   certificate, private_key and keystore_password parameters to be set.
#
# @param status
#   To define the status of the service. If set to `enabled`, the service will
#   be run and will be started at boot time. If set to `disabled`, the service
#   is stopped and will not be started at boot time. If set to `running`, the
#   service will be run but will not be started at boot time. You may use this
#   to start a service on the first Puppet run instead of the system startup.
#   If set to `unmanaged`, the service will not be started at boot time and Puppet
#   does not care whether the service is running or not. For example, this may
#   be useful if a cluster management software is used to decide when to start
#   the service plus assuring it is running on the desired node.
#
# @param system_key
#   Source for the Shield system key. Valid values are any that are
#   supported for the file resource `source` parameter.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::instance (
  Enum['absent', 'present']          $ensure                        = $elasticsearch::ensure,
  Optional[Stdlib::Absolutepath]     $ca_certificate                = undef,
  Optional[Stdlib::Absolutepath]     $certificate                   = undef,
  Optional[Hash]                     $config                        = undef,
  Stdlib::Absolutepath               $configdir                     = "${elasticsearch::configdir}/${name}",
  String                             $daily_rolling_date_pattern    = $elasticsearch::daily_rolling_date_pattern,
  Optional[Elasticsearch::Multipath] $datadir                       = undef,
  Boolean                            $datadir_instance_directories  = $elasticsearch::datadir_instance_directories,
  Boolean                            $deprecation_logging           = false,
  String                             $deprecation_logging_level     = 'DEBUG',
  String                             $file_rolling_type             = $elasticsearch::file_rolling_type,
  Hash                               $init_defaults                 = {},
  Optional[Stdlib::Absolutepath]     $init_defaults_file            = undef,
  String                             $init_template                 = $elasticsearch::init_template,
  Array[String]                      $jvm_options                   = $elasticsearch::jvm_options,
  Optional[String]                   $keystore_password             = undef,
  Optional[Stdlib::Absolutepath]     $keystore_path                 = undef,
  Stdlib::Absolutepath               $logdir                        = "${elasticsearch::logdir}/${name}",
  Hash                               $logging_config                = {},
  Optional[String]                   $logging_file                  = undef,
  String                             $logging_level                 = $elasticsearch::default_logging_level,
  Optional[String]                   $logging_template              = undef,
  Optional[Stdlib::Absolutepath]     $private_key                   = undef,
  Boolean                            $purge_secrets                 = $elasticsearch::purge_secrets,
  Integer                            $rolling_file_max_backup_index = $elasticsearch::rolling_file_max_backup_index,
  String                             $rolling_file_max_file_size    = $elasticsearch::rolling_file_max_file_size,
  Optional[Hash]                     $secrets                       = undef,
  Optional[Enum['shield', 'x-pack']] $security_plugin               = $elasticsearch::security_plugin,
  Optional[String]                   $service_flags                 = undef,
  Boolean                            $ssl                           = false,
  Elasticsearch::Status              $status                        = $elasticsearch::status,
  Optional[String]                   $system_key                    = $elasticsearch::system_key,
) {

  File {
    owner => $elasticsearch::elasticsearch_user,
    group => $elasticsearch::elasticsearch_group,
  }

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  if $ssl or ($system_key != undef) {
    if $security_plugin == undef or ! ($security_plugin in ['shield', 'x-pack']) {
      fail("\"${security_plugin}\" is not a valid security_plugin parameter value")
    }
  }

  $notify_service = $elasticsearch::restart_config_change ? {
    true  => Elasticsearch::Service[$name],
    false => undef,
  }

  if ($ensure == 'present') {

    # Configuration hash
    if ($config == undef) {
      $instance_config = {}
    } else {
      $instance_config = deep_implode($config)
    }

    if(has_key($instance_config, 'node.name')) {
      $instance_node_name = {}
    } else {
      $instance_node_name = { 'node.name' => "${::hostname}-${name}" }
    }

    # String or array for data dir(s)
    if ($datadir == undef) {
      if ($datadir_instance_directories) {
        if $elasticsearch::datadir =~ Array {
          $instance_datadir = array_suffix($elasticsearch::datadir, "/${name}")
        } else {
          $instance_datadir = "${elasticsearch::datadir}/${name}"
        }
      } else {
        $instance_datadir = $elasticsearch::datadir
      }
    } else {
      $instance_datadir = $datadir
    }

    # Logging file or hash
    if ($logging_file != undef) {
      $logging_source = $logging_file
      $logging_content = undef
      $_log4j_content = undef
    } elsif ($elasticsearch::logging_file != undef) {
      $logging_source = $elasticsearch::logging_file
      $logging_content = undef
      $_log4j_content = undef
    } else {

      $main_logging_config = deep_implode($elasticsearch::logging_config)
      $instance_logging_config = deep_implode($logging_config)

      $logging_hash = merge(
        # Shipped defaults
        {
          'action'                 => 'DEBUG',
          'com.amazonaws'          => 'WARN',
          'index.search.slowlog'   => 'TRACE, index_search_slow_log_file',
          'index.indexing.slowlog' => 'TRACE, index_indexing_slow_log_file',
        },
        $main_logging_config,
        $instance_logging_config
      )
      if ($logging_template != undef ) {
        $logging_content = template($logging_template)
        $_log4j_content = template($logging_template)
      } elsif ($elasticsearch::logging_template != undef) {
        $logging_content = template($elasticsearch::logging_template)
        $_log4j_content = template($elasticsearch::logging_template)
      } else {
        $logging_content = template("${module_name}/etc/elasticsearch/logging.yml.erb")
        $_log4j_content = template("${module_name}/etc/elasticsearch/log4j2.properties.erb")
      }
      $logging_source = undef
    }

    $main_config = deep_implode($elasticsearch::config)

    $instance_datadir_config = { 'path.data' => $instance_datadir }

    if $instance_datadir =~ Array {
      $dirs = join($instance_datadir, ' ')
    } else {
      $dirs = $instance_datadir
    }

    if $ssl {
      if ($keystore_password == undef) {
        fail('keystore_password required')
      }

      if ($keystore_path == undef) {
        $_keystore_path = "${configdir}/${security_plugin}/${name}.ks"
      } else {
        validate_absolute_path($keystore_path)
        $_keystore_path = $keystore_path
      }

      if $security_plugin == 'shield' {
        $tls_config = {
          'shield.transport.ssl'         => true,
          'shield.http.ssl'              => true,
          'shield.ssl.keystore.path'     => $_keystore_path,
          'shield.ssl.keystore.password' => $keystore_password,
        }
      } elsif $security_plugin == 'x-pack' {
        $tls_config = {
          'xpack.security.transport.ssl.enabled' => true,
          'xpack.security.http.ssl.enabled'      => true,
          'xpack.ssl.keystore.path'              => $_keystore_path,
          'xpack.ssl.keystore.password'          => $keystore_password,
        }
      }

      # Trust CA Certificate
      java_ks { "elasticsearch_instance_${name}_keystore_ca":
        ensure       => 'latest',
        certificate  => $ca_certificate,
        target       => $_keystore_path,
        password     => $keystore_password,
        trustcacerts => true,
      }

      # Load node certificate and private key
      java_ks { "elasticsearch_instance_${name}_keystore_node":
        ensure      => 'latest',
        certificate => $certificate,
        private_key => $private_key,
        target      => $_keystore_path,
        password    => $keystore_password,
      }
    } else { $tls_config = {} }

    exec { "mkdir_logdir_elasticsearch_${name}":
      command => "mkdir -p ${logdir}",
      creates => $logdir,
      require => Class['elasticsearch::package'],
      before  => File[$logdir],
    }

    file { $logdir:
      ensure  => 'directory',
      group   => $elasticsearch::elasticsearch_group,
      owner   => $elasticsearch::elasticsearch_user,
      mode    => '0750',
      require => Class['elasticsearch::package'],
      before  => Elasticsearch::Service[$name],
    }

    if ($datadir_instance_directories) {
      exec { "mkdir_datadir_elasticsearch_${name}":
        command => "mkdir -p ${dirs}",
        creates => $instance_datadir,
        require => Class['elasticsearch::package'],
        before  => Elasticsearch::Service[$name],
      }
      -> file { $instance_datadir:
        ensure  => 'directory',
        owner   => $elasticsearch::elasticsearch_user,
        group   => undef,
        mode    => '0755',
        require => Class['elasticsearch::package'],
        before  => Elasticsearch::Service[$name],
      }
    }

    exec { "mkdir_configdir_elasticsearch_${name}":
      command => "mkdir -p ${configdir}",
      creates => $elasticsearch::configdir,
      require => Class['elasticsearch::package'],
      before  => Elasticsearch::Service[$name],
    }
    -> file { $configdir:
      ensure       => 'directory',
      # Copy files from the stock configuration directory _into_ the instance
      # configuration directory. This lets us pull in miscellaneous files that
      # utilities may create (like X-Pack user/role files) into instance
      # directories without explicitly naming them, since we can't predict all the
      # files that plugins may create/manage.
      #
      # Special care is needed to avoid copying in _some_ directories/files to
      # avoid overwriting instance-specific configuration files or other instance
      # directories.
      ignore       => [
        "${elasticsearch::configdir}/elasticsearch.yml",
        "${elasticsearch::configdir}/jvm.options",
        "${elasticsearch::configdir}/logging.yml",
        "${elasticsearch::configdir}/log4j2.properties",
      ],
      recurse      => 'remote',
      recurselimit => 1,
      source       => $elasticsearch::configdir,
      purge        => $elasticsearch::purge_configdir,
      force        => $elasticsearch::purge_configdir,
      tag          => [
        'elasticsearch_instance_configdir',
      ],
      require      => Class['elasticsearch::package'],
      before       => Elasticsearch::Service[$name],
      notify       => $notify_service,
    }

    # Do _not_ copy in instance directories. This avoids a) recursing
    # indefinitely by copying our own instance directory and b) copying in any
    # other potential instance directories.
    File <| tag == 'elasticsearch_instance_configdir' |> {
      ignore +> $name
    }

    file { "${configdir}/jvm.options":
      before  => Elasticsearch::Service[$name],
      content => template("${module_name}/etc/elasticsearch/jvm.options.erb"),
      group   => $elasticsearch::elasticsearch_group,
      notify  => $notify_service,
      owner   => $elasticsearch::elasticsearch_user,
    }

    file {
      "${configdir}/logging.yml":
        ensure  => file,
        content => $logging_content,
        source  => $logging_source,
        mode    => '0644',
        notify  => $notify_service,
        require => Class['elasticsearch::package'],
        before  => Elasticsearch::Service[$name];
      "${configdir}/log4j2.properties":
        ensure  => file,
        content => $_log4j_content,
        source  => $logging_source,
        mode    => '0644',
        notify  => $notify_service,
        require => Class['elasticsearch::package'],
        before  => Elasticsearch::Service[$name];
    }

    if $security_plugin != undef {
      file { "${configdir}/${security_plugin}":
        ensure  => 'directory',
        mode    => '0750',
        source  => "${elasticsearch::configdir}/${security_plugin}",
        recurse => 'remote',
        owner   => 'root',
        group   => $elasticsearch::elasticsearch_group,
        before  => Elasticsearch::Service[$name],
        notify  => $notify_service,
      }
    }

    if $system_key != undef {
      file { "${configdir}/${security_plugin}/system_key":
        ensure  => 'file',
        source  => $system_key,
        mode    => '0400',
        before  => Elasticsearch::Service[$name],
        require => File["${configdir}/${security_plugin}"],
      }
    }

    # build up new config
    $instance_conf = merge(
      $main_config,
      $instance_node_name,
      $instance_datadir_config,
      { 'path.logs' => $logdir },
      $tls_config,
      $instance_config
    )

    # defaults file content
    # ensure user did not provide both init_defaults and init_defaults_file
    if ((!empty($init_defaults)) and ($init_defaults_file != undef)) {
      fail ('Only one of $init_defaults and $init_defaults_file should be defined')
    }

    $init_defaults_new = merge(
      { 'DATA_DIR'  => $elasticsearch::_datadir_default },
      $elasticsearch::init_defaults,
      {
        'CONF_DIR'       => $configdir,
        'ES_HOME'        => $elasticsearch::homedir,
        'ES_JVM_OPTIONS' => "${configdir}/jvm.options",
        'ES_PATH_CONF'   => $configdir,
        'LOG_DIR'        => $logdir,
      },
      $init_defaults
    )

    $user = $elasticsearch::elasticsearch_user
    $group = $elasticsearch::elasticsearch_group

    datacat_fragment { "main_config_${name}":
      target => "${configdir}/elasticsearch.yml",
      data   => $instance_conf,
    }

    datacat { "${configdir}/elasticsearch.yml":
      template => "${module_name}/etc/elasticsearch/elasticsearch.yml.erb",
      notify   => $notify_service,
      require  => Class['elasticsearch::package'],
      owner    => $elasticsearch::elasticsearch_user,
      group    => $elasticsearch::elasticsearch_group,
      mode     => '0440',
    }

    if ($elasticsearch::secrets != undef or $secrets != undef) {
      if ($elasticsearch::secrets != undef) {
        $main_secrets = $elasticsearch::secrets
      } else {
        $main_secrets = {}
      }

      if ($secrets != undef) {
        $instance_secrets = $secrets
      } else {
        $instance_secrets = {}
      }

      elasticsearch_keystore { $name :
        configdir => $elasticsearch::configdir,
        purge     => $purge_secrets,
        settings  => merge($main_secrets, $instance_secrets),
        notify    => $notify_service,
      }
    }

    $require_service = Class['elasticsearch::package']
    $before_service  = undef

  } else {

    file { $configdir:
      ensure  => 'absent',
      recurse => true,
      force   => true,
    }

    $require_service = undef
    $before_service  = File[$configdir]

    $init_defaults_new = {}
  }

  elasticsearch::service { $name:
    ensure             => $ensure,
    status             => $status,
    service_flags      => $service_flags,
    init_defaults      => $init_defaults_new,
    init_defaults_file => $init_defaults_file,
    init_template      => $init_template,
    require            => $require_service,
    before             => $before_service,
  }
}
