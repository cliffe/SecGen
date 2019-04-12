# This class exists to coordinate all service management related actions,
# functionality and logical units in a central place.
#
# *Note*: "service" is the Puppet term and type for background processes
# in general and is used in a platform-independent way. E.g. "service" means
# "daemon" in relation to Unix-like systems.
#
# @param ensure
#   Controls if the managed resources shall be `present` or
#   `absent`. If set to `absent`, the managed software packages will being
#   uninstalled and any traces of the packages will be purged as well as
#   possible. This may include existing configuration files (the exact
#   behavior is provider). This is thus destructive and should be used with
#   care.
#
# @param init_template
#   Service file as a template
#
# @param pid_dir
#   Directory where to store the serice pid file.
#
# @param service_flags
#   Flags to pass to the service.
#
# @param status
#   Defines the status of the service. If set to `enabled`, the service is
#   started and will be enabled at boot time. If set to `disabled`, the
#   service is stopped and will not be started at boot time. If set to `running`,
#   the service is started but will not be enabled at boot time. You may use
#   this to start a service on the first Puppet run instead of the system startup.
#   If set to `unmanaged`, the service will not be started at boot time and Puppet
#   does not care whether the service is running or not. For example, this may
#   be useful if a cluster management software is used to decide when to start
#   the service plus assuring it is running on the desired node.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::service::openbsd (
  Enum['absent', 'present'] $ensure        = $elasticsearch::ensure,
  Optional[String]          $init_template = $elasticsearch::init_template,
  Optional[String]          $pid_dir       = $elasticsearch::pid_dir,
  Optional[String]          $service_flags = undef,
  Elasticsearch::Status     $status        = $elasticsearch::status,
) {

  #### Service management

  if $ensure == 'present' {

    case $status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      # do not start service on boot, do not care whether currently running
      # or not
      'unmanaged': {
        $service_ensure = undef
        $service_enable = false
      }
      default: { }
    }
  } else {

    # make sure the service is stopped and disabled (the removal itself will be
    # done by package.pp)
    $service_ensure = 'stopped'
    $service_enable = false

  }

  $notify_service = $elasticsearch::restart_config_change ? {
    true  => Service["elasticsearch-instance-${name}"],
    false => undef,
  }

  if ($status != 'unmanaged') {
    # Note that service files are persisted even in the case of absent instances.
    # This is to ensure that manifest can remain idempotent and have the service
    # file available in order to permit Puppet to introspect system state.
    # init file from template
    if ($init_template != undef) {
      elasticsearch_service_file { "/etc/rc.d/elasticsearch_${name}":
        ensure       => 'present',
        content      => file($init_template),
        instance     => $name,
        pid_dir      => $pid_dir,
        notify       => $notify_service,
        package_name => 'elasticsearch',
      }
      -> file { "/etc/rc.d/elasticsearch_${name}":
        ensure => 'file',
        owner  => 'root',
        group  => '0',
        mode   => '0555',
        before => Service["elasticsearch-instance-${name}"],
        notify => $notify_service,
      }
    }

    # action
    service { "elasticsearch-instance-${name}":
      ensure => $service_ensure,
      enable => $service_enable,
      name   => "elasticsearch_${name}",
      flags  => $service_flags,
    }
  }
}
