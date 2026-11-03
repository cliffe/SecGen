# @summary Configure Host elements in $CATALINA_BASE/conf/server.xml
#
# @param app_base
#    Specifies the Application Base directory for the virtual host. Maps to the [appBase XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes). Valid options: a string.
# @param catalina_base
#   Specifies the base directory of the Tomcat installation to manage. Valid options: a string containing an absolute path.
# @param host_ensure
#   Specifies whether the virtual host (the [Host XML element](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Introduction)) should exist in the configuration file.
# @param host_name
#   Specifies the network name of the virtual host, as registered on your DNS server. Maps to the [name XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes). Valid options: a string.
# @param parent_service
#   Specifies which Service element the Host should nest under. Valid options: a string containing the name attribute of the Service.
# @param additional_attributes
#   Specifies any further attributes to add to the Host. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param aliases
#   Optional array that specifies the list of [Host Name Aliases](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Host_Name_Aliases) for this particular Host.  If omitted, any currently-defined Aliases will not be altered.  If present, the list Aliases  will be set to exactly match the contents of this array.  Thus, for example, an empty array can be used to explicitly force there to be no Aliases for the Host.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::host (
  Optional[String[1]] $app_base                 = undef,
  Optional[Stdlib::Absolutepath] $catalina_base = undef,
  Enum['present','absent'] $host_ensure         = 'present',
  Optional[String[1]] $host_name                = undef,
  String $parent_service                        = 'Catalina',
  Hash $additional_attributes                   = {},
  Array $attributes_to_remove                   = [],
  Optional[String[1]] $server_config            = undef,
  Optional[Array] $aliases                      = undef,
  Boolean $show_diff                            = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $host_name {
    $_host_name = $host_name
  } else {
    $_host_name = $name
  }

  $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine/Host[#attribute/name='${_host_name}']"

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $host_ensure == 'absent' or $host_ensure == false {
    $changes = "rm ${base_path}"
  } else {
    if ! $app_base {
      fail('$app_base must be specified if you aren\'t removing the host')
    }

    $_host_name_change = "set ${base_path}/#attribute/name ${_host_name}"
    $_app_base = "set ${base_path}/#attribute/appBase ${app_base}"

    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }

    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    if $aliases {
      $_clear_aliases = "rm ${base_path}/Alias"
      $_add_aliases = suffix(prefix($aliases, "set ${base_path}/Alias[last()+1]/#text '"), "'")
    } else {
      $_clear_aliases = undef
      $_add_aliases = undef
    }

    $changes = delete_undef_values(flatten([
          $_host_name_change,
          $_app_base,
          $_additional_attributes,
          $_attributes_to_remove,
          $_clear_aliases,
          $_add_aliases,
    ]))
  }

  augeas { "${_catalina_base}-${parent_service}-host-${name}":
    lens      => 'Xml.lns',
    incl      => $_server_config,
    changes   => $changes,
    show_diff => $show_diff,
  }
}
