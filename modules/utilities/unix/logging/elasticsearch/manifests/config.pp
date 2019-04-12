# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
# @example importing this class into other classes to use its functionality:
#   class { 'elasticsearch::config': }
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class elasticsearch::config {

  #### Configuration

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  if ( $elasticsearch::ensure == 'present' ) {

    file {
      $elasticsearch::configdir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => 'root',
        mode   => '2750';
      $elasticsearch::datadir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user;
      $elasticsearch::logdir:
        ensure  => 'directory',
        group   => $elasticsearch::elasticsearch_group,
        owner   => $elasticsearch::elasticsearch_user,
        mode    => '0750',
        recurse => true;
      $elasticsearch::plugindir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => 'o+Xr';
      "${elasticsearch::homedir}/lib":
        ensure  => 'directory',
        group   => '0',
        owner   => 'root',
        recurse => true;
      $elasticsearch::homedir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user;
      "${elasticsearch::homedir}/templates_import":
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => '0755';
      "${elasticsearch::homedir}/scripts":
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => '0755';
      "${elasticsearch::configdir}/scripts":
        ensure  => 'directory',
        source  => "${elasticsearch::homedir}/scripts",
        mode    => '0755',
        recurse => 'remote',
        owner   => $elasticsearch::elasticsearch_user,
        group   => $elasticsearch::elasticsearch_group;
      '/etc/elasticsearch/elasticsearch.yml':
        ensure => 'absent';
      '/etc/elasticsearch/jvm.options':
        ensure => 'absent';
      '/etc/elasticsearch/logging.yml':
        ensure => 'absent';
      '/etc/elasticsearch/log4j2.properties':
        ensure => 'absent';
    }

    if $elasticsearch::pid_dir {
      file { $elasticsearch::pid_dir:
        ensure  => 'directory',
        group   => undef,
        owner   => $elasticsearch::elasticsearch_user,
        recurse => true,
      }

      if ($elasticsearch::service_provider == 'systemd') {
        $group = $elasticsearch::elasticsearch_group
        $user = $elasticsearch::elasticsearch_user
        $pid_dir = $elasticsearch::pid_dir

        file { '/usr/lib/tmpfiles.d/elasticsearch.conf':
          ensure  => 'file',
          content => template("${module_name}/usr/lib/tmpfiles.d/elasticsearch.conf.erb"),
          group   => '0',
          owner   => 'root',
        }
      }
    }

    if ($elasticsearch::service_provider == 'systemd') {
      # Mask default unit (from package)
      service { 'elasticsearch' :
        ensure => false,
        enable => 'mask',
      }
    } else {
      service { 'elasticsearch':
        ensure => false,
        enable => false,
      }
    }

    if $elasticsearch::defaults_location {
      augeas { "${elasticsearch::defaults_location}/elasticsearch":
        incl    => "${elasticsearch::defaults_location}/elasticsearch",
        lens    => 'Shellvars.lns',
        changes => [
          'rm CONF_FILE',
          'rm CONF_DIR',
          'rm ES_PATH_CONF',
        ],
      }

      file { "${elasticsearch::defaults_location}/elasticsearch":
        ensure => 'file',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => '0640';
      }
    }

    if $::elasticsearch::security_plugin != undef and ($::elasticsearch::security_plugin in ['shield', 'x-pack']) {
      file { "${::elasticsearch::configdir}/${::elasticsearch::security_plugin}" :
        ensure => 'directory',
        owner  => 'root',
        group  => $elasticsearch::elasticsearch_group,
        mode   => '0750',
      }
    }

    # Define logging config file for the in-use security plugin
    if $::elasticsearch::security_logging_content != undef or $::elasticsearch::security_logging_source != undef {
      if $::elasticsearch::security_plugin == undef or ! ($::elasticsearch::security_plugin in ['shield', 'x-pack']) {
        fail("\"${::elasticsearch::security_plugin}\" is not a valid security_plugin parameter value")
      }

      $_security_logging_file = $::elasticsearch::security_plugin ? {
        'shield' => 'logging.yml',
        default => 'log4j2.properties'
      }

      file { "/etc/elasticsearch/${::elasticsearch::security_plugin}/${_security_logging_file}" :
        content => $::elasticsearch::security_logging_content,
        source  => $::elasticsearch::security_logging_source,
      }
    }

  } elsif ( $elasticsearch::ensure == 'absent' ) {

    file { $elasticsearch::plugindir:
      ensure => 'absent',
      force  => true,
      backup => false,
    }

    file { "${elasticsearch::configdir}/jvm.options":
      ensure => 'absent',
    }

  }

}
