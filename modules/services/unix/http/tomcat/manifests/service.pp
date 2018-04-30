# Definition: tomcat::service
#
# Service management for Tomcat.
#
# Parameters:
# - $catalina_home is the root of the Tomcat installation.
# - $catalina_base is the base directory for the Tomcat installation.
# - Whether or not to $use_jsvc for service management. Boolean defaulting to
#   false. If both $use_jsvc and $use_init are false,
#   $CATALINA_BASE/bin/catalina.sh start and $CATALIN/A_BASE/bin/catalina.sh
#   stop are used for service management.
# - If using jsvc, optionally set java_home.  Has no affect unless
#   $use_jsvc = true.
# - $service_ensure is passed on to the service resource.
# - $service_enable specifies whether the tomcat service should be enabled on
#   on boot. Valid options are 'true' or 'false'. Defaults to 'undef', will be
#   programmatically set to 'true' if $use_init is true AND
#   $service_ensure == 'running'
# - Whether or not to $use_init for service management. Boolean defaulting to
#   false. If both $use_jsvc and $use_init are false,
#   $CATALINA_BASE/bin/catalina.sh start and $CATALINA_BASE/bin/catalina.sh
#   stop are used for service management.
# - The $service_name to use for the packaged init script
# - The $start_command to use for the service
# - The $stop_command to use for the service
# - $user is the user of the jsvc process.
define tomcat::service (
  $catalina_home  = undef,
  $catalina_base  = undef,
  $use_jsvc       = false,
  $use_init       = false,
  $java_home      = undef,
  $service_ensure = running,
  $service_enable = undef,
  $service_name   = undef,
  $start_command  = undef,
  $stop_command   = undef,
  $user           = undef,
) {
  include tomcat
  $_user = pick($user, $::tomcat::user)
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

  validate_bool($use_jsvc)
  validate_bool($use_init)

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
    $_status       = "ps p `cat ${_catalina_base}/logs/jsvc.pid` > /dev/null"
    $_provider     = 'base'
  } elsif $use_init {
    $_service_name = $service_name
    $_hasstatus    = true
    $_hasrestart   = true
    $_start        = $start_command
    $_stop         = $stop_command
    $_status       = undef
    $_provider     = undef
  } else {
    $_service_name = "tomcat-${name}"
    $_hasstatus    = false
    $_hasrestart   = false
    $_start        = $start_command ? {
      undef   => "su -s /bin/bash -c 'CATALINA_HOME=${_catalina_home} CATALINA_BASE=${_catalina_base} ${_catalina_home}/bin/catalina.sh start' ${_user}",
      default => $start_command
    }
    $_stop         = $stop_command ? {
      undef   => "su -s /bin/bash -c 'CATALINA_HOME=${_catalina_home} CATALINA_BASE=${_catalina_base} ${_catalina_home}/bin/catalina.sh stop' ${_user}",
      default => $stop_command
    }
    $_status       = "ps aux | grep 'catalina.base=${_catalina_base} ' | grep -v grep"
    $_provider     = 'base'
  }

  if $use_init {
    if $service_enable != undef {
      validate_bool($service_enable)
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
