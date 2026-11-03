# @summary Configures roles and users in $CATALINA_BASE/conf/tomcat-users.xml or any other specified file
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation. Valid options: a string containing an absolute path.
# @param element
#   Specifies the type of element to manage.
# @param element_name
#   Sets the element's username (or rolename, if `element` is set to 'role'). Valid options: a string. `$name`.
# @param ensure
#   Determines whether the specified XML element should exist in the configuration file.
# @param file
#   Specifies the configuration file to manage. Valid options: a string containing a fully-qualified path.
# @param manage_file
#   Specifies whether to create the specified configuration file if it doesn't exist. Uses Puppet's native [file](https://docs.puppetlabs.com/references/latest/type.html#file) with default parameters.
# @param owner
#   Specifies the owner of the configuration file. `$::tomcat::user`.
# @param group
#   Specifies the group of the configuration file. `$::tomcat::group`.
# @param password
#   Specifies a password for user elements. Valid options: a string.
# @param roles
#   Specifies one or more roles. Only valid if `element` is set to 'role' or 'user'. Valid options: an array of strings.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::tomcat_users (
  Stdlib::Absolutepath $catalina_base                     = $tomcat::catalina_home,
  Enum['user','role'] $element                            = 'user',
  Optional[String[1]] $element_name                       = undef,
  Enum['present','absent'] $ensure                        = present,
  Optional[String[1]] $file                               = undef,
  Boolean $manage_file                                    = true,
  Optional[String[1]] $owner                              = undef,
  Optional[String[1]] $group                              = undef,
  Optional[Variant[String, Sensitive[String]]] $password  = undef,
  Array $roles                                            = [],
  Boolean $show_diff                                      = true,
) {
  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $password_unsensitive = if $password =~ Sensitive { $password.unwrap } else { $password }
  $_owner = pick($owner, $tomcat::user)
  $_group = pick($group, $tomcat::group)

  if $element == 'role' and ( $password or ! empty($roles) ) {
    warning('$password and $roles are useless when $element is set to \'role\'')
  }

  if $element == 'user' {
    $element_identifier = 'username'
  } else {
    $element_identifier = 'rolename'
  }

  if $element_name {
    $_element_name = $element_name
  } else {
    $_element_name = $name
  }

  if $file {
    $_file = $file
  } else {
    $_file = "${catalina_base}/conf/tomcat-users.xml"
  }

  if $manage_file {
    ensure_resource('file', $_file, {
        ensure  => file,
        path    => $_file,
        replace => false,
        content => '<?xml version=\'1.0\' encoding=\'utf-8\'?><tomcat-users></tomcat-users>',
        owner   => $_owner,
        group   => $_group,
        mode    => '0640',
    })
    File[$_file] -> Augeas["${catalina_base}-tomcat_users-${element}-${_element_name}-${name}"]
  }

  $path = "tomcat-users/${element}[#attribute/${element_identifier}='${_element_name}']"

  if $ensure == 'absent' {
    $add_entry = undef
    $remove_entry = "rm ${path}"
    $add_password = undef
    $add_roles = undef
  } else {
    $add_entry = "set ${path}/#attribute/${element_identifier} '${_element_name}'"
    $remove_entry = undef
    if $element == 'user' {
      $add_password = "set ${path}/#attribute/password '${password_unsensitive}'"
      $add_roles = join(["set ${path}/#attribute/roles '",join($roles, ','),"'"])
    } else {
      $add_password = undef
      $add_roles = undef
    }
  }

  $changes = delete_undef_values([$remove_entry, $add_entry, $add_password, $add_roles])

  augeas { "${catalina_base}-tomcat_users-${element}-${_element_name}-${name}":
    lens      => 'Xml.lns',
    incl      => $_file,
    changes   => $changes,
    show_diff => $show_diff,
  }
}
