# Definition: tomcat::war
#
# Manage deployment of WAR files.
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation
# - $app_base is the path relative to $catalina_base to deploy the WAR to.
#   Defaults to 'webapps'.
# - The $deployment_path can optionally be specified. Only one of $app_base and
#   $deployment_path can be specified.
# - $war_ensure specifies whether you are trying to add or remove the WAR.
#   Valid values are 'present', 'absent', 'true', and 'false'. Defaults to
#   'present'.
# _ Optionally specify a $war_name. Defaults to $name.
# - $war_purge is a boolean specifying whether or not to purge the exploded WAR
#   directory. Defaults to true. Only applicable when $war_ensure is 'absent'
#   or 'false'. Note: if tomcat is running and autodeploy is on, setting
#   $war_purge to false won't stop tomcat from auto-undeploying exploded WARs.
# - $war_source is the source to deploy the WAR from. Currently supports
#   http(s)://, puppet://, and ftp:// paths. $war_source must be specified
#   unless $war_ensure is set to 'false' or 'absent'.
define tomcat::war(
  $catalina_base   = undef,
  $app_base        = undef,
  $deployment_path = undef,
  $war_ensure      = 'present',
  $war_name        = undef,
  $war_purge       = true,
  $war_source      = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))
  validate_re($war_ensure, '^(present|absent|true|false)$')
  validate_bool($war_purge)

  if $app_base and $deployment_path {
    fail('Only one of $app_base and $deployment_path can be specified.')
  }

  if $war_name {
    $_war_name = $war_name
  } else {
    $_war_name = $name
  }

  validate_re($_war_name, '\.war$')

  if $deployment_path {
    $_deployment_path = $deployment_path
  } else {
    if $app_base {
      $_app_base = $app_base
    } else {
      $_app_base = 'webapps'
    }
    $_deployment_path = "${_catalina_base}/${_app_base}"
  }

  if $war_ensure =~ /^(absent|false)$/ {
    file { "${_deployment_path}/${_war_name}":
      ensure => absent,
      force  => false,
    }
    if $war_purge {
      $war_dir_name = regsubst($_war_name, '\.war$', '')
      if $war_dir_name != '' {
        file { "${_deployment_path}/${war_dir_name}":
          ensure => absent,
          force  => true,
        }
      }
    }
  } else {
    if ! $war_source {
      fail('$war_source must be specified if you aren\'t removing the WAR')
    }
    staging::file { $name:
      source => $war_source,
      target => "${_deployment_path}/${_war_name}",
    }
  }
}
