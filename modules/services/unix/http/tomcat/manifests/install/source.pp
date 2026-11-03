# @summary Private define to install Tomcat from source.
#
# @api private
#
define tomcat::install::source (
  String[1] $catalina_home,
  Boolean   $manage_home,
  String[1]  $source_url,
  Boolean   $source_strip_first_dir,
  String[1] $group,
  Boolean   $allow_insecure                                   = false,
  String[1] $user                                             = 'root',
  Optional[Enum['none', 'http', 'https', 'ftp']] $proxy_type  = undef,
  Optional[String[1]] $proxy_server                           = undef,
) {
  tag(sha1($catalina_home))

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $source_strip_first_dir {
    $_strip = 1
  } else {
    $_strip = 0
  }

  $filename = regsubst($source_url, '.*/(.*)', '\1')

  if $manage_home {
    file { $catalina_home:
      ensure => directory,
      owner  => $user,
      group  => $group,
    }
  }

  archive { "${name}-${catalina_home}/${filename}":
    path           => "${catalina_home}/${filename}",
    source         => $source_url,
    extract        => true,
    extract_path   => $catalina_home,
    creates        => "${catalina_home}/NOTICE",
    extract_flags  => "--strip ${_strip} -xf",
    cleanup        => true,
    allow_insecure => $allow_insecure,
    user           => $user,
    group          => $group,
    proxy_server   => $proxy_server,
    proxy_type     => $proxy_type,
  }
}
