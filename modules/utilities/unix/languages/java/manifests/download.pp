# Defined Type java::download
#
# @summary
#   Installs Java from a url location.
#
#
# @param ensure
#   Install or remove the package.
#
# @param version
#   Version of Java to install, e.g. '7' or '8'. Default values for major and minor versions will be used.
#
# @param version_major
#   Major version which should be installed, e.g. '8u101'. Must be used together with version_minor.
#
# @param version_minor
#   Minor version which should be installed, e.g. 'b12'. Must be used together with version_major.
#
# @param java_se
#   Type of Java Standard Edition to install, jdk or jre.
#
# @param proxy_server
#   Specify a proxy server, with port number if needed. ie: https://example.com:8080. (passed to archive)
#
# @param proxy_type
#   Proxy server type (none|http|https|ftp). (passed to archive)
#
# @param url
#   Full URL
#
# @param jce
#   Install Oracles Java Cryptographic Extensions into the JRE or JDK
#
# @param jce_url
#   Full URL to the jce zip file
#
# @param basedir
#   Directory under which the installation will occur. If not set, defaults to
#   /usr/lib/jvm for Debian and /usr/java for RedHat.
#
# @param manage_basedir
#   Whether to manage the basedir directory.  Defaults to false.
#   Note: /usr/lib/jvm is managed for Debian by default, separate from this parameter.
#
# @param package_type
#   Type of installation package for specified version of java_se. java_se 6 comes
#   in a few installation package flavors and we need to account for them.
#   Optional forced package types: rpm, rpmbin, tar.gz
#
# @param manage_symlink
#   Whether to manage a symlink that points to the installation directory.  Defaults to false.
#
# @param symlink_name
#   The name for the optional symlink in the installation directory.
#
define java::download(
  $ensure         = 'present',
  $version        = '8',
  $version_major  = undef,
  $version_minor  = undef,
  $java_se        = 'jdk',
  $proxy_server   = undef,
  $proxy_type     = undef,
  $url            = undef,
  $jce            = false,
  $jce_url        = undef,
  $basedir        = undef,
  $manage_basedir = false,
  $package_type   = undef,
  $manage_symlink = false,
  $symlink_name   = undef,
) {

  # archive module is used to download the java package
  include archive

  # validate java Standard Edition to download
  if $java_se !~ /(jre|jdk)/ {
    fail('Java SE must be either jre or jdk.')
  }

  if $jce {
    if $jce_url {
      $jce_download = $jce_url
    } else {
      fail('JCE URL must be specified')
    }
  }

  # determine Java major and minor version, and installation path
  if $version_major and $version_minor {

    $label         = $version_major
    $release_major = $version_major
    $release_minor = $version_minor

    if $release_major =~ /(\d+)u(\d+)/ {
      # Required for CentOS systems where Java8 update number is >= 171 to ensure
      # the package is visible to Puppet. This is only true for installations that
      # don't use the tar.gz package type.
      if $facts['os']['family'] == 'RedHat' and Numeric($2) >= 171 and $package_type != 'tar.gz' {
        $install_path = "${java_se}1.${1}.0_${2}-amd64"
      } else {
        $install_path = "${java_se}1.${1}.0_${2}"
      }
    } else {
      $install_path = "${java_se}${release_major}${release_minor}"
    }
  } else {
    # use default versions if no specific major and minor version parameters are provided
    $label = $version
    case $version {
      '6' : {
        $release_major = '6u45'
        $release_minor = 'b06'
        $install_path = "${java_se}1.6.0_45"
      }
      '7' : {
        $release_major = '7u80'
        $release_minor = 'b15'
        $install_path = "${java_se}1.7.0_80"
      }
      '8' : {
        $release_major = '8u201'
        $release_minor = 'b09'
        $install_path = "${java_se}1.8.0_201"
      }
      default : {
        $release_major = '8u201'
        $release_minor = 'b09'
        $install_path = "${java_se}1.8.0_201"
      }
    }
  }

  # determine package type (exe/tar/rpm), destination directory based on OS
  case $facts['kernel'] {
    'Linux' : {
      case $facts['os']['family'] {
        'RedHat', 'Amazon' : {
          # Oracle Java 6 comes in a special rpmbin format
          if $package_type {
            $_package_type = $package_type
          } elsif $version == '6' {
            $_package_type = 'rpmbin'
          } else {
            $_package_type = 'rpm'
          }
          if $basedir {
            $_basedir = $basedir
          } else {
            $_basedir = '/usr/java'
          }
        }
        'Debian' : {
          if $package_type {
            $_package_type = $package_type
          } else {
            $_package_type = 'tar.gz'
          }
          if $basedir {
            $_basedir = $basedir
          } else {
            $_basedir = '/usr/lib/jvm'
          }
        }
        default : {
          fail ("unsupported platform ${$facts['os']['name']}") }
      }

      $creates_path = "${_basedir}/${install_path}"
      $os = 'linux'
      $destination_dir = '/tmp/'
    }
    default : {
      fail ( "unsupported platform ${$facts['kernel']}" ) }
  }

  # Install required unzip packages for jce
  if $jce {
    ensure_resource('package', 'unzip', { 'ensure' => 'present' })
  }

  # set java architecture nomenclature
  $os_architecture = $facts['os']['architecture'] ? {
    undef => $facts['os']['architecture'],
    default => $facts['os']['architecture']
  }

  case $os_architecture {
    'i386' : { $arch = 'i586' }
    'x86_64' : { $arch = 'x64' }
    'amd64' : { $arch = 'x64' }
    default : {
      fail ("unsupported platform ${$os_architecture}")
    }
  }

  # following are based on this example:
  # http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jre-7u80-linux-i586.rpm
  #
  # JaveSE 6 distributed in .bin format
  # http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-i586-rpm.bin
  # http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-i586.bin
  # package name to use in destination directory for the installer
  case $_package_type {
    'bin' : {
      $package_name = "${java_se}-${release_major}-${os}-${arch}.bin"
    }
    'rpmbin' : {
      $package_name = "${java_se}-${release_major}-${os}-${arch}-rpm.bin"
    }
    'rpm' : {
      $package_name = "${java_se}-${release_major}-${os}-${arch}.rpm"
    }
    'tar.gz' : {
      $package_name = "${java_se}-${release_major}-${os}-${arch}.tar.gz"
    }
    default : {
      $package_name = "${java_se}-${release_major}-${os}-${arch}.rpm"
    }
  }

  # if complete URL is provided, use this value for source in archive resource
  if $url {
    $source = $url
  }
  else {
    fail('Url must be specified')
  }

  # full path to the installer
  $destination = "${destination_dir}${package_name}"
  notice ("Destination is ${destination}")

  case $_package_type {
    'bin' : {
      $install_command = "sh ${destination}"
    }
    'rpmbin' : {
      $install_command = "sh ${destination} -x; rpm --force -iv sun*.rpm; rpm --force -iv ${java_se}*.rpm"
    }
    'rpm' : {
      $install_command = "rpm --force -iv ${destination}"
    }
    'tar.gz' : {
      $install_command = "tar -zxf ${destination} -C ${_basedir}"
    }
    default : {
      $install_command = "rpm -iv ${destination}"
    }
  }

  case $ensure {
    'present' : {
      archive { $destination :
        ensure       => present,
        source       => $source,
        extract_path => '/tmp',
        cleanup      => false,
        creates      => $creates_path,
        proxy_server => $proxy_server,
        proxy_type   => $proxy_type,
      }
      case $facts['kernel'] {
        'Linux' : {
          case $facts['os']['family'] {
            'Debian' : {
              ensure_resource('file', $_basedir, {
                ensure => directory,
              })
              $install_requires = [Archive[$destination], File[$_basedir]]
            }
            default : {
              $install_requires = [Archive[$destination]]
            }
          }

          if $manage_basedir {
            ensure_resource('file', $_basedir, {'ensure' => 'directory', 'before' => Exec["Install Oracle java_se ${java_se} ${version} ${release_major} ${release_minor}"]})
          }

          exec { "Install Oracle java_se ${java_se} ${version} ${release_major} ${release_minor}" :
            path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
            command => $install_command,
            creates => $creates_path,
            require => $install_requires,
          }

          if ($manage_symlink and $symlink_name) {
            file { "${_basedir}/${symlink_name}":
              ensure  => link,
              target  => $creates_path,
              require => Exec["Install Oracle java_se ${java_se} ${version} ${release_major} ${release_minor}"],
            }
          }

          if ($jce and $jce_download != undef) {
            $jce_path = $java_se ? {
              'jre' => "${creates_path}/lib/security",
              'jdk' => "${creates_path}/jre/lib/security"
            }
            archive { "/tmp/jce-${version}.zip":
              source        => $jce_download,
              extract       => true,
              extract_path  => $jce_path,
              extract_flags => '-oj',
              creates       => "${jce_path}/US_export_policy.jar",
              cleanup       => false,
              proxy_server  => $proxy_server,
              proxy_type    => $proxy_type,
              require       => [
                Package['unzip'],
                Exec["Install Oracle java_se ${java_se} ${version} ${release_major} ${release_minor}"]
              ],
            }
          }
        }
        default : {
          fail ("unsupported platform ${$facts['kernel']}")
        }
      }
    }
    default : {
      notice ("Action ${ensure} not supported.")
    }
  }
}
