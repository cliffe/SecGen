# Definition: tomcat::config::server::host
#
# Configure Host elements in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $app_base is the appBase attribute for the Host. This parameter is required
#   unless $host_ensure is set to 'false' or 'absent'.
# - $catalina_base is the base directory for the Tomcat installation.
# - $host_ensure specifies whether you are trying to add or remove the Host
#   element. Valid values are 'true', 'false', 'present', and 'absent'. Defaults
#   to 'present'.
# - $host_name is the name attribute for the Host. Defaults to $name.
# - $parent_service is the Service element this Host should be nested beneath.
#   Defaults to 'Catalina'
# - An optional hash of $additional_attributes to add to the Host. Should be of
#   the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Host.
# - $aliases is an optional array of aliases for the Host.  If omitted, the
#   set of Alias elements within the Host element will not be altered.
#   Otherwise, the set of Alias elements will be set to exactly match the
#   contents of this array.  An empty array can be used to ensure that there
#   are no Alias elements within the Host element.
define tomcat::config::server::host (
  $app_base              = undef,
  $catalina_base         = undef,
  $host_ensure           = 'present',
  $host_name             = undef,
  $parent_service        = 'Catalina',
  $additional_attributes = {},
  $attributes_to_remove  = [],
  $server_config         = undef,
  $aliases               = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($host_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)

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

  if $host_ensure =~ /^(absent|false)$/ {
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
      validate_array($aliases)
      $_clear_aliases = "rm ${base_path}/Alias"
      $_add_aliases = suffix(prefix($aliases, "set ${base_path}/Alias[last()+1]/#text '"), "'")
    } else {
      $_clear_aliases = undef
      $_add_aliases = undef
    }

    $changes = delete_undef_values(flatten([$_host_name_change, $_app_base, $_additional_attributes, $_attributes_to_remove, $_clear_aliases, $_add_aliases]))
  }

  augeas { "${_catalina_base}-${parent_service}-host-${name}":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $changes,
  }
}
