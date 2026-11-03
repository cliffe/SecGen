# @summary Service management for Tomcat.
#
# @param catalina_home
#   Specifies the root directory of the Tomcat installation. Valid options: a string containing an absolute path.
# @param catalina_base
#   Specifies the base directory of the Tomcat installation. Valid options: a string containing an absolute path.
# @param use_jsvc
#   Specifies whether to use Jsvc for service management. If both `use_jsvc` and `use_init` are set to `false`, tomcat uses the following commands for service management.
#   ```
#   $CATALINA_HOME/bin/catalina.sh start
#   $CATALINA_HOME/bin/catalina.sh stop
#   ```
# @param use_init
#   Specifies whether to use a package-provided init script for service management.
# @param java_home
#   Specifies where Java is installed. Only applies if `use_jsvc` is set to `true`. Valid options: a string containing an absolute path.
# @param service_ensure
#   Specifies whether the Tomcat service should be running. Maps to the `ensure` parameter of Puppet's native [service](https://docs.puppetlabs.com/references/latest/type.html#service). Valid options: 'running', 'stopped', `true`, `false`.
# @param service_enable
#   Specifies whether to enable the Tomcat service at boot. Only valid if `use_init` is set to `true`. `true`, if `use_init` is set to `true` and `service_ensure` is set to 'running' or `true`.
# @param service_name
#    Specifies the name of the Tomcat service. Valid options: a string.
# @param start_command
#   Designates a command to start the service. Valid options: a string. `use_init` and `use_jsvc`.
# @param stop_command
#   Designates a command to stop the service. Valid options: a string. `use_init` and `use_jsvc`.
# @param status_command
#   Designates a command to get the status of the service. Valid options: a string. `use_init` and `use_jsvc`.
# @param user
#   The user of the jsvc process when `use_init => true`
# @param wait_timeout
#   The wait timeout set in the jsvc init script when `use_init => true` and `use_jsvc => true`
#
define tomcat::service (
  Optional[String[1]]                         $catalina_home   = undef,
  Optional[Stdlib::Absolutepath]              $catalina_base   = undef,
  Boolean                                     $use_jsvc        = false,
  Boolean                                     $use_init        = false,
  Optional[String[1]]                         $java_home       = undef,
  Enum['running', 'stopped', 'true', 'false'] $service_ensure  = running,
  Optional[Boolean]                           $service_enable  = undef,
  Optional[String[1]]                         $service_name    = undef,
  Optional[String[1]]                         $start_command   = undef,
  Optional[String[1]]                         $stop_command    = undef,
  Optional[String[1]]                         $status_command  = undef,
  Optional[String[1]]                         $user            = undef,
  Integer                                     $wait_timeout    = 10,
) {
  include tomcat
  $_user = pick($user, $tomcat::user)
  # XXX Backwards compatibility: If the user declares a base but not a home, we
  # assume they are in compatibility mode
  if $catalina_base {
    $_catalina_home = pick($catalina_home, $catalina_base)
  } else {
    $_catalina_home = pick($catalina_home, $tomcat::catalina_home)
  }
  $_catalina_base = pick($catalina_base, $_catalina_home) #default to home
  tag(sha1($_catalina_home))
  tag(sha1($_catalina_base))

  if $use_init and ! $use_jsvc and ! $service_name {
    fail('service_name must be specified when using the package init script')
  }

  if $use_init and ! $use_jsvc and $catalina_home {
    warning('catalina_home has no effect when using the package init script; ignoring')
  }

  if $use_jsvc and $service_name {
    warning('service_name has no effect when using jsvc; ignoring')
  }

  if ! $use_init and $service_enable != undef {
    warning('service_enable has no effect without an init script; ignoring')
  }

  if ! $use_jsvc and $java_home {
    warning('java_home has no effect when not using jsvc; ignoring')
  }

  if $use_jsvc and $use_init {
    $_service_name = "tomcat-${name}"
    $_hasstatus    = true
    $_hasrestart   = true
    $_start        = "service tomcat-${name} start"
    $_stop         = "service tomcat-${name} stop"
    $_status       = "service tomcat-${name} status"
    $_provider     = undef
    # Template uses:
    # - $_catalina_home
    # - $_catalina_base
    # - $java_home
    # - $_user
    file { "/etc/init.d/tomcat-${name}":
      mode    => '0755',
      content => template('tomcat/jsvc-init.erb'),
    }
  } elsif $use_jsvc {
    if $java_home {
      $_jsvc_home = "-home ${java_home} "
    } else {
      $_jsvc_home = undef
    }
    $_service_name = "tomcat-${name}"
    $_hasstatus    = false
    $_hasrestart   = false
    if $start_command {
      $_start = $start_command
    } else {
      $_start = "export CATALINA_HOME=${_catalina_home}; export CATALINA_BASE=${_catalina_base}; \
                 \$CATALINA_HOME/bin/jsvc \
                   ${_jsvc_home}-user ${_user} \
                   -classpath \$CATALINA_HOME/bin/bootstrap.jar:\$CATALINA_HOME/bin/tomcat-juli.jar \
                   -outfile \$CATALINA_BASE/logs/catalina.out \
                   -errfile \$CATALINA_BASE/logs/catalina.err \
                   -pidfile \$CATALINA_BASE/logs/jsvc.pid \
                   -Dcatalina.home=\$CATALINA_HOME \
                   -Dcatalina.base=\$CATALINA_BASE \
                   -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
                   -Djava.util.logging.config.file=\$CATALINA_BASE/conf/logging.properties \
                   org.apache.catalina.startup.Bootstrap"
    }
    if $stop_command {
      $_stop = $stop_command
    } else {
      $_stop = "export CATALINA_HOME=${_catalina_home}; export CATALINA_BASE=${_catalina_base};
                 \$CATALINA_HOME/bin/jsvc \
                   -pidfile \$CATALINA_BASE/logs/jsvc.pid \
                   -stop org.apache.catalina.startup.Bootstrap"
    }
    if $status_command {
      $_status = $status_command
    } else {
      $_status     = "ps p `cat ${_catalina_base}/logs/jsvc.pid` > /dev/null"
    }
    $_provider     = 'base'
  } elsif $use_init {
    $_service_name = $service_name
    $_hasstatus    = true
    $_hasrestart   = true
    $_start        = $start_command
    $_stop         = $stop_command
    $_status       = $status_command
    $_provider     = undef
  } else {
    $_service_name = "tomcat-${name}"
    $_hasstatus    = false
    $_hasrestart   = false
    $_start        = $start_command ? {
      undef   => "su -s /bin/bash -c 'CATALINA_HOME=${_catalina_home} CATALINA_BASE=${_catalina_base} ${_catalina_home}/bin/catalina.sh start' ${_user}", # lint:ignore:140chars
      default => $start_command
    }
    $_stop         = $stop_command ? {
      undef   => "su -s /bin/bash -c 'CATALINA_HOME=${_catalina_home} CATALINA_BASE=${_catalina_base} ${_catalina_home}/bin/catalina.sh stop' ${_user}", # lint:ignore:140chars
      default => $stop_command
    }
    $_status       = $status_command ? {
      undef   => "ps aux | grep 'catalina.base=${_catalina_base} ' | grep -v grep",
      default => $status_command
    }
    $_provider     = 'base'
  }

  if $use_init {
    if $service_enable != undef {
      $_service_enable = $service_enable
    } else {
      $_service_enable = $service_ensure ? {
        'running' => true,
        true      => true,
        default   => undef,
      }
    }
  } else {
    $_service_enable = undef
  }

  service { $_service_name:
    ensure     => $service_ensure,
    enable     => $_service_enable,
    hasstatus  => $_hasstatus,
    hasrestart => $_hasrestart,
    start      => $_start,
    stop       => $_stop,
    status     => $_status,
    provider   => $_provider,
  }
}
