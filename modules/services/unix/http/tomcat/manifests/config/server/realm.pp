# @summary Configure Realm elements in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation. 
# @param class_name
#   Specifies the Java class name of a Realm implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html#Common_Attributes). Valid options: a string containing a Java class name. `name` passed in your defined type.
# @param name
#   `$class_name`
# @param realm_ensure
#   Specifies whether the Realm element should exist in the configuration file.
# @param parent_service
#   Specifies which Service element this Realm element should nest under. Valid options: a string containing the name attribute of the Service.
# @param parent_engine
#   Specifies which Engine element this Realm should nest under. Valid options: a string containing the name attribute of the Engine.
# @param parent_host
#   Specifies which Host element this Realm should nest under. Valid options: a string containing the name attribute of the Host.
# @param parent_realm
#   Specifies which Realm element this Realm should nest under. Valid options: a string containing the className attribute of the Realm element.
# @param additional_attributes
#   Specifies any further attributes to add to the Realm element. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param purge_realms
#   Specifies whether to purge any unmanaged Realm elements from the configuration file.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::realm (
  Optional[String[1]] $catalina_base      = undef,
  String[1] $class_name                   = $name,
  Enum['present','absent'] $realm_ensure  = 'present',
  String $parent_service                  = 'Catalina',
  String $parent_engine                   = 'Catalina',
  Optional[String[1]] $parent_host        = undef,
  Optional[String[1]] $parent_realm       = undef,
  Hash $additional_attributes             = {},
  Array $attributes_to_remove             = [],
  Optional[Boolean] $purge_realms         = undef,
  Optional[String[1]] $server_config      = undef,
  Boolean $show_diff                      = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))
  $_purge_realms = pick($purge_realms, $tomcat::purge_realms)

  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $_purge_realms and ($realm_ensure == 'absent') {
    fail('$realm_ensure must be set to \'present\' to use $purge_realms')
  }

  if $_purge_realms {
    # Perform deletions in reverse depth order as workaround for
    # https://github.com/hercules-team/augeas/issues/319
    $__purge_realms = [
      'rm //Realm//Realm',
      'rm //Context//Realm',
      'rm //Host//Realm',
      'rm //Engine//Realm',
      'rm //Server//Realm',
    ]
  } else {
    $__purge_realms = undef
  }

  $engine_path = "Server/Service[#attribute/name='${parent_service}']/Engine[#attribute/name='${parent_engine}']"

  # The Realm may be nested under a Host element.
  if $parent_host {
    $host_path = "${engine_path}/Host[#attribute/name='${parent_host}']"
  } else {
    $host_path = $engine_path
  }

  # The Realm could also be nested under another Realm element if the parent realm is a CombinedRealm.
  if $parent_realm {
    $path = "${host_path}/Realm[#attribute/className='${parent_realm}']/Realm"
  } else {
    $path = "${host_path}/Realm"
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  # For backwards-compatible reasons, match previously managed realms that do
  # not have puppetName but have a known className. Either we match puppetName
  # or className; puppet could not have created a state in which two realms
  # match.
  $path_expression = "#attribute/puppetName='${name}' or (count(#attribute/puppetName)=0 and #attribute/className='${class_name}')"

  if $realm_ensure == 'absent' {
    $changes = "rm ${path}[${path_expression}]"
  } else {
    # This will create the node if there are no matches
    $_class_name = "set ${path}[${path_expression}]/#attribute/className '${class_name}'"
    $puppet_name = "set ${path}[${path_expression}]/#attribute/puppetName '${name}'"

    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"),
      "set ${path}[${path_expression}]/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${path}[${path_expression}]/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([
          $__purge_realms,
          $puppet_name,
          $_class_name,
          $_additional_attributes,
          $_attributes_to_remove,
    ]))
  }

  augeas { "${_catalina_base}-${parent_service}-${parent_engine}-${parent_host}-${parent_realm}-realm-${name}":
    lens      => 'Xml.lns',
    incl      => $_server_config,
    changes   => $changes,
    show_diff => $show_diff,
  }
}
