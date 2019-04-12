# Definition: tomcat::install::source
#
# Private define to install Tomcat from source.
#
# Parameters:
# - $catalina_home is the root of the Tomcat installation.
# - The $source_url to install from.
# - $source_strip_first_dir is a boolean specifying whether or not to strip
#   the first directory when unpacking the source tarball. Defaults to true
#   when installing from source on non-Solaris systems. Requires puppet/staging
#   > 0.4.0
# - $environment is variables for settings such as http_proxy, https_proxy, or ftp_proxy
define tomcat::install::source (
  $catalina_home,
  $manage_home,
  $source_url,
  $source_strip_first_dir,
  $user,
  $group,
  $environment = undef,
) {
  tag(sha1($catalina_home))
  include ::staging

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $source_strip_first_dir {
    $_strip = 1
  }

  $filename = regsubst($source_url, '.*/(.*)', '\1')

  if $manage_home {
    file { $catalina_home:
      ensure => directory,
      owner  => $user,
      group  => $group,
    }
  }

  ensure_resource('staging::file',$filename, {
    'source'      => $source_url,
    'environment' => $environment,
  })

  staging::extract { "${name}-${filename}":
    source      => "${::staging::path}/tomcat/${filename}",
    target      => $catalina_home,
    require     => Staging::File[$filename],
    unless      => "test -f ${catalina_home}/NOTICE",
    user        => $user,
    group       => $group,
    environment => $environment,
    strip       => $_strip,
  }
}
