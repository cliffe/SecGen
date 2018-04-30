# Definition tomcat::config::server::tomcat_users
#
# Configures roles and users in $CATALINA_BASE/conf/tomcat-users.xml
# or any other specified file
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation
# - $element specifies the element type. Valid values are 'user' or 'role'.
#   Defaults to 'user'.
# - $element_name sets the 'username' or 'rolename'. Depends on the $element.
#   Defaults to $name.
# - $ensure specifies whether you are trying to add or remove the element.
#   Valid values are 'present', 'absent', 'true', and 'false'. Defaults to
#   'present'.
# - $file: The path to the file to manage. Must be fully qualified.
#   Defaults to $CATALINA_BASE/conf/tomcat-users.xml.
# - Set $manage_file to true for managing the file. It sets file permission,
#   owner, group and create a basic tomcat-users XML if file does not exist yet.
# - $owner specifies the owner of the file if $manage_file is true. Default: $tomcat::user
# - $group specifies the group of the file if $manage_file is true. Default: $tomcat::group
# - $password specifies the password for a user ($element = 'user').
# - $roles specifies the roles for a user ($element = 'user').
#
define tomcat::config::server::tomcat_users (
  $catalina_base = $::tomcat::catalina_home,
  $element       = 'user',
  $element_name  = undef,
  $ensure        = present,
  $file          = undef,
  $manage_file   = true,
  $owner         = undef,
  $group         = undef,
  $password      = undef,
  $roles         = [],
) {

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $_owner = pick($owner, $::tomcat::user)
  $_group = pick($group, $::tomcat::group)

  validate_re($element, '^(user|role)$')
  validate_re($ensure, '^(present|absent|true|false)$')
  validate_array($roles)
  validate_bool($manage_file)

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
  }

  $path = "tomcat-users/${element}[#attribute/${element_identifier}='${_element_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $add_entry = undef
    $remove_entry = "rm ${path}"
    $add_password = undef
    $add_roles = undef
  } else {
    $add_entry = "set ${path}/#attribute/${element_identifier} '${_element_name}'"
    $remove_entry = undef
    if $element == 'user' {
      $add_password = "set ${path}/#attribute/password '${password}'"
      $add_roles = join(["set ${path}/#attribute/roles '",join($roles, ','),"'"])
    } else {
      $add_password = undef
      $add_roles = undef
    }
  }

  $changes = delete_undef_values([$remove_entry, $add_entry, $add_password, $add_roles])

  augeas { "${catalina_base}-tomcat_users-${element}-${_element_name}-${name}":
    lens    => 'Xml.lns',
    incl    => $_file,
    changes => $changes,
    require => File[$_file],
  }

}
