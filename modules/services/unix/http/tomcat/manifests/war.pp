# @summary Manage deployment of WAR files.
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation. Valid options: a string containing an absolute path. `$::tomcat::catalina_home`.
# @param app_base
#   Specifies where to deploy the WAR. Cannot be used in combination with `deployment_path`. Valid options: a string containing a path relative to `$CATALINA_BASE`. `app_base`, Puppet deploys the WAR to your specified `deployment_path`. If you don't specify that either, the WAR deploys to `${catalina_base}/webapps`.
# @param deployment_path
#   Specifies where to deploy the WAR. Cannot be used in combination with `app_base`. Valid options: a string containing an absolute path. `deployment_path`, Puppet deploys the WAR to your specified `app_base`. If you don't specify that either, the WAR deploys to `${catalina_base}/webapps`.
# @param war_ensure
#   Specifies whether the WAR should exist.
# @param war_name
#   Specifies the name of the WAR. Valid options: a string containing a filename that ends in '.war'. `name` passed in your defined type.
# @param war_purge
#   Specifies whether to purge the exploded WAR directory. Only applicable when `war_ensure` is set to 'absent' or `false`.
# @param war_source
#    Specifies the source to deploy the WAR from. Valid options: a string containing a `puppet://`, `http(s)://`, or `ftp://` URL.
# @param allow_insecure
#   Specifies if HTTPS errors should be ignored when downloading the war tarball.
# @param user
#   The 'owner' of the tomcat war file. 
# @param group
#   The 'group' owner of the tomcat war file. 
#
define tomcat::war (
  Optional[Stdlib::Absolutepath] $catalina_base   = undef,
  Optional[String[1]]            $app_base        = undef,
  Optional[String[1]]            $deployment_path = undef,
  Enum['present','absent']       $war_ensure      = 'present',
  Optional[String[1]]            $war_name        = undef,
  Boolean                        $war_purge       = true,
  Optional[String[1]]            $war_source      = undef,
  Boolean                        $allow_insecure  = false,
  String[1]                      $user            = 'tomcat',
  String[1]                      $group           = 'tomcat',
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if $app_base and $deployment_path {
    fail('Only one of $app_base and $deployment_path can be specified.')
  }

  if $war_name {
    $_war_name = $war_name
  } else {
    $_war_name = $name
  }

  if $_war_name !~ /\.war$/ {
    fail('war_name must end with .war')
  }

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

  if $war_ensure == 'absent' {
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
    archive { "tomcat::war ${name}":
      extract        => false,
      source         => $war_source,
      path           => "${_deployment_path}/${_war_name}",
      allow_insecure => $allow_insecure,
    }
    file { "tomcat::war ${name}":
      ensure    => file,
      path      => "${_deployment_path}/${_war_name}",
      owner     => $user,
      group     => $group,
      mode      => '0640',
      subscribe => Archive["tomcat::war ${name}"],
    }
  }
}
