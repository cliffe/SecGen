# @summary Configure Engine elements in $CATALINA_BASE/conf/server.xml
#
# @param default_host
#   Specifies a host to handle any requests directed to hostnames that exist on the server but are not defined in this configuration file. Maps to the [defaultHost XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) of the Engine. Valid options: a string containing a hostname.
# @param catalina_base
#   Specifies the base directory of the Tomcat installation to manage. Valid options: a string containing an absolute path.
# @param background_processor_delay
#   Determines the delay between invoking the backgroundProcess method on this engine and its child containers. Maps to the [backgroundProcessorDelay XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes). Valid options: an integer, in seconds. `undef`.
# @param background_processor_delay_ensure
#   Specifies whether the [backgroundProcessorDelay XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) should exist in the configuration file.
# @param class_name
#   Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes). Valid options: a string containing a Java class name.
# @param class_name_ensure
#   Specifies whether the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) should exist in the configuration file.
# @param engine_name
#   Specifies the logical name of the Engine, used in log and error messages. Maps to the [name XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes). Valid options: a string. `name` passed in your defined type.
# @param jvm_route
#   Specifies an identifier to enable session affinity in load balancing. Maps to the [jvmRoute XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes). Valid options: string.
# @param jvm_route_ensure
#   Specifies whether the [jvmRoute XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) should exist in the configuration file.
# @param parent_service
#   Specifies which Service element the Engine should nest under. Valid options: a string containing the name attribute of the Service.
# @param start_stop_threads
#   Sets how many threads the Engine should use to start child Host elements in parallel. Maps to the [startStopThreads XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes). 
#   Valid options: a string or an integer. Warning: Future versions of the module will deprecate Strings as a valid value and allow only Integers.
# @param start_stop_threads_ensure
#   Specifies whether the [startStopThreads XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) should exist in the configuration file.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::engine (
  String[1] $default_host,
  Optional[Stdlib::Absolutepath] $catalina_base                     = undef,
  Optional[Variant[Integer, String[1]]] $background_processor_delay = undef,
  Enum['present','absent'] $background_processor_delay_ensure       = 'present',
  Optional[String[1]] $class_name                                   = undef,
  Enum['present','absent'] $class_name_ensure                       = 'present',
  Optional[String[1]] $engine_name                                  = undef,
  Optional[String[1]] $jvm_route                                    = undef,
  Enum['present','absent'] $jvm_route_ensure                        = 'present',
  String[1] $parent_service                                         = 'Catalina',
  Optional[Variant[String[1], Integer]] $start_stop_threads         = undef,
  Enum['present','absent'] $start_stop_threads_ensure               = 'present',
  Optional[String[1]] $server_config                                = undef,
  Boolean $show_diff                                                = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $engine_name {
    $_name = $engine_name
  } else {
    $_name = $name
  }

  $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine"

  $_name_change = "set ${base_path}/#attribute/name ${_name}"
  $_default_host = "set ${base_path}/#attribute/defaultHost ${default_host}"

  if $background_processor_delay_ensure == 'absent' {
    $_background_processor_delay = "rm ${base_path}/#attribute/backgroundProcessorDelay"
  } elsif $background_processor_delay {
    $_background_processor_delay = "set ${base_path}/#attribute/backgroundProcessorDelay ${background_processor_delay}"
  } else {
    $_background_processor_delay = undef
  }

  if $class_name_ensure == 'absent' {
    $_class_name = "rm ${base_path}/#attribute/className"
  } elsif $class_name {
    $_class_name = "set ${base_path}/#attribute/className ${class_name}"
  } else {
    $_class_name = undef
  }

  if $jvm_route_ensure == 'absent' {
    $_jvm_route = "rm ${base_path}/#attribute/jvmRoute"
  } elsif $jvm_route {
    $_jvm_route = "set ${base_path}/#attribute/jvmRoute ${jvm_route}"
  } else {
    $_jvm_route = undef
  }

  if $start_stop_threads_ensure == 'absent' {
    $_start_stop_threads = "rm ${base_path}/#attribute/startStopThreads"
  } elsif $start_stop_threads {
    $_start_stop_threads = "set ${base_path}/#attribute/startStopThreads ${start_stop_threads}"
  } else {
    $_start_stop_threads = undef
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  $changes = delete_undef_values([
      $_name_change,
      $_default_host,
      $_background_processor_delay,
      $_class_name,
      $_jvm_route,
      $_start_stop_threads,
  ])

  augeas { "${_catalina_base}-${parent_service}-engine":
    lens      => 'Xml.lns',
    incl      => $_server_config,
    changes   => $changes,
    show_diff => $show_diff,
  }
}
