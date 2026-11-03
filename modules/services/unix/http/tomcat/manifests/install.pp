# @summary Configure and manage the tomcat installation
#
# @param catalina_home
#   specifies the directory of the Tomcat installation from which the instance should be created. Valid options: a string containing an absolute path. 
# @param name
#   `$catalina_home`
# @param install_from_source
#   Specifies whether to install from source or from a package. If set to `true` installation uses the `source_url`, `source_strip_first_dir`, `user`, `group`, `manage_user`, and `manage_group` parameters. If set to `false` installation uses the `package_ensure`, `package_name`, and `package_options` parameters. Valid options: Boolean. `true`.
# @param source_url
#   In single-instance mode:  Specifies the source URL to install from. Valid options: a string containing a `puppet://`, `http(s)://`, or `ftp://` URL.
# @param source_strip_first_dir
#   Specifies whether to strip the topmost directory of the tarball when unpacking it. Only valid if `install_from_source` is set to `true`.
# @param proxy_type
#   Specifies the proxy server type used by `proxy_server`. Normally this defaults to the protocol specified in the `proxy_server` URI. `proxy_server`. Valid options: 'none', 'http', 'https', 'ftp'.
# @param proxy_server
#   Specifies a proxy server to use when downloading Tomcat binaries. For example, 'https://example.com:8080'.
# @param allow_insecure
#   Specifies if HTTPS errors should be ignored when downloading the source tarball. Valid options: Boolean.
# @param user
#   Specifies the owner of the source installation directory. `$::tomcat::user`.
# @param group
#   Specifies the group of the source installation directory. `$::tomcat::group`.
# @param manage_user
#   Specifies whether the user should be managed by this module or not. `$::tomcat::manage_user`.
# @param manage_group
#   Specifies whether the group should be managed by this module or not. `$::tomcat::manage_group`.
# @param manage_home
#   Specifies whether the directory of catalina_home should be managed by puppet. This may not be preferable in network filesystem environments.
# @param package_ensure
#   Determines whether the specified package should be installed. Only valid if `install_from_source` is set to `false`. Maps to the `ensure` parameter of Puppet's native [package](https://docs.puppetlabs.com/references/latest/type.html#package).
# @param package_name
#    Specifies the package to install. Valid options: a string containing a valid package name.
# @param package_options
#    Specify additional options to use on the generated package resource. See the documentation of the [package](https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options) for possible values.
# @param remove_default_webapps
#    Specifies the default webapps to be removed.
#
define tomcat::install (
  String[1] $catalina_home                                   = $name,
  Boolean $install_from_source                               = true,

  # source options
  Optional[String[1]] $source_url                            = undef,
  Boolean $source_strip_first_dir                            = true,
  Optional[Enum['none', 'http', 'https', 'ftp']] $proxy_type = undef,
  Optional[String[1]] $proxy_server                          = undef,
  Boolean $allow_insecure                                    = false,
  Optional[String[1]] $user                                  = undef,
  Optional[String[1]] $group                                 = undef,
  Optional[Boolean]   $manage_user                           = undef,
  Optional[Boolean]   $manage_group                          = undef,
  Optional[Boolean] $manage_home                             = undef,
  Optional[Array[String[1]]] $remove_default_webapps         = undef,

  # package options
  Optional[String[1]]        $package_ensure   = undef,
  Optional[String[1]]        $package_name     = undef,
  Optional[Array[String[1]]] $package_options  = undef,
) {
  include tomcat
  $_user = pick($user, $tomcat::user)
  $_group = pick($group, $tomcat::group)
  $_manage_user = pick($manage_user, $tomcat::manage_user)
  $_manage_group = pick($manage_group, $tomcat::manage_group)
  $_manage_home = pick($manage_home, $tomcat::manage_home)
  tag(sha1($catalina_home))

  if $install_from_source {
    if $_manage_user {
      ensure_resource('user', $_user, {
          ensure => present,
          gid    => $_group,
      })
    }
    if $_manage_group {
      ensure_resource('group', $_group, {
          ensure => present,
      })
    }
    tomcat::install::source { $name:
      catalina_home          => $catalina_home,
      manage_home            => $_manage_home,
      source_url             => $source_url,
      source_strip_first_dir => $source_strip_first_dir,
      proxy_type             => $proxy_type,
      proxy_server           => $proxy_server,
      allow_insecure         => $allow_insecure,
      user                   => $_user,
      group                  => $_group,
    }
  } else {
    tomcat::install::package { $package_name:
      package_ensure  => $package_ensure,
      package_options => $package_options,
    }
  }

  if $remove_default_webapps {
    $remove_default_webapps.each |$folder| {
      $require_value = $install_from_source? {
        true    => Resource['tomcat::install::source', $name],
        default => Resource['tomcat::install::package', $package_name]
      }

      file { "remove ${folder}" :
        ensure  => absent,
        path    => "${catalina_home}/webapps/${folder}",
        recurse => true,
        purge   => true,
        force   => true,
        require => $require_value,
      }
    }
  }
}
