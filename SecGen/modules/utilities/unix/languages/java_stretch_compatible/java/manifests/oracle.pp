# Defined Type java::oracle
#
# Description
# Installs Oracle Java. By using this module you agree to the Oracle licensing
# agreement.
#
# Install one or more versions of Oracle Java.
#
# uses the following to download the package and automatically accept
# the licensing terms.
# wget --no-cookies --no-check-certificate --header \
# "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
# "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz"
#
# Parameters
# [*version*]
# Version of Java to install, e.g. '7' or '8'. Default values for major and minor
# versions will be used.
#
# [*version_major*]
# Major version which should be installed, e.g. '8u101'. Must be used together with
# version_minor.
#
# [*version_minor*]
# Minor version which should be installed, e.g. 'b12'. Must be used together with
# version_major.
#
# [*java_se*]
# Type of Java Standard Edition to install, jdk or jre.
#
# [*ensure*]
# Install or remove the package.
#
# [*oracle_url*]
# Official Oracle URL to download binaries from.
#
# [*proxy_server*]
# Specify a proxy server, with port number if needed. ie: https://example.com:8080. (passed to archive)
#
# [*proxy_type*]
# Proxy server type (none|http|https|ftp). (passed to archive)
#
# Variables
# [*release_major*]
# Major version release number for java_se. Used to construct download URL.
#
# [*release_minor*]
# Minor version release number for java_se. Used to construct download URL.
#
# [*install_path*]
# Base install path for specified version of java_se. Used to determine if java_se
# has already been installed.
#
# [*package_type*]
# Type of installation package for specified version of java_se. java_se 6 comes
# in a few installation package flavors and we need to account for them.
#
# [*os*]
# Oracle java_se OS type.
#
# [*destination*]
# Destination directory to save java_se installer to.  Usually /tmp on Linux and
# C:\TEMP on Windows.
#
# [*creates_path*]
# Fully qualified path to java_se after it is installed. Used to determine if
# java_se is already installed.
#
# [*arch*]
# Oracle java_se architecture type.
#
# [*package_name*]
# Name of the java_se installation package to download from Oracle's website.
#
# [*install_command*]
# Installation command used to install Oracle java_se. Installation commands
# differ by package_type. 'bin' types are installed via shell command. 'rpmbin'
# types have the rpms extracted and then forcibly installed. 'rpm' types are
# forcibly installed.
#
# [*url*]
# Full URL, including oracle_url, release_major, release_minor and package_name, to
# download the Oracle java_se installer. Originally present but not used, activated
# to workaround MODULES-5058
#
# [*url_hash*]
# Directory hash used by the download.oracle.com site.  This value is a 32 character string
# which is part of the file URL returned by the JDK download site.
#
# ### Author
# mike@marseglia.org
#
define java::oracle (
  $ensure        = 'present',
  $version       = '8',
  $version_major = undef,
  $version_minor = undef,
  $java_se       = 'jdk',
  $oracle_url    = 'http://download.oracle.com/otn-pub/java/jdk/',
  $proxy_server  = undef,
  $proxy_type    = undef,
  $url           = undef,
  $url_hash      = undef,
) {

  # archive module is used to download the java package
  include ::archive

  # validate java Standard Edition to download
  if $java_se !~ /(jre|jdk)/ {
    fail('Java SE must be either jre or jdk.')
  }

  # determine Oracle Java major and minor version, and installation path
  if $version_major and $version_minor {

    $release_major = $version_major
    $release_minor = $version_minor
    $release_hash  = $url_hash

    if $release_major =~ /(\d+)u(\d+)/ {
      $install_path = "${java_se}1.${1}.0_${2}"
    } else {
      $install_path = "${java_se}${release_major}${release_minor}"
    }
  } else {
    # use default versions if no specific major and minor version parameters are provided
    case $version {
      '6' : {
        $release_major = '6u45'
        $release_minor = 'b06'
        $install_path = "${java_se}1.6.0_45"
        $release_hash  = undef
      }
      '7' : {
        $release_major = '7u80'
        $release_minor = 'b15'
        $install_path = "${java_se}1.7.0_80"
        $release_hash  = undef
      }
      '8' : {
        $release_major = '8u131'
        $release_minor = 'b11'
        $install_path = "${java_se}1.8.0_131"
        $release_hash  = 'd54c1d3a095b4ff2b6607d096fa80163'
      }
      default : {
        $release_major = '8u131'
        $release_minor = 'b11'
        $install_path = "${java_se}1.8.0_131"
        $release_hash  = 'd54c1d3a095b4ff2b6607d096fa80163'
      }
    }
  }

  # determine package type (exe/tar/rpm), destination directory based on OS
  case $facts['kernel'] {
    'Linux' : {
      case $facts['os']['family'] {
        'RedHat', 'Amazon' : {
          # Oracle Java 6 comes in a special rpmbin format
          if $version == '6' {
            $package_type = 'rpmbin'
          } else {
            $package_type = 'rpm'
          }
          $creates_path = "/usr/java/${install_path}"
        }
        'Debian' : {
            $package_type = 'tar.gz'
            $creates_path = "/usr/lib/jvm/${install_path}"
        }
        default : {
          fail ("unsupported platform ${$facts['os']['name']}") }
      }

      $os = 'linux'
      $destination_dir = '/tmp/'
    }
    default : {
      fail ( "unsupported platform ${$facts['kernel']}" ) }
  }

  # set java architecture nomenclature
  case $facts['os']['architecture'] {
    'i386' : { $arch = 'i586' }
    'x86_64' : { $arch = 'x64' }
    'amd64' : { $arch = 'x64' }
    default : {
      fail ("unsupported platform ${$facts['os']['architecture']}")
    }
  }

  # following are based on this example:
  # http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jre-7u80-linux-i586.rpm
  #
  # JaveSE 6 distributed in .bin format
  # http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-i586-rpm.bin
  # http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-i586.bin
  # package name to download from Oracle's website
  case $package_type {
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
  elsif $release_hash != undef {
    $source = "${oracle_url}/${release_major}-${release_minor}/${release_hash}/${package_name}"
  }
  else {
    $source = "${oracle_url}/${release_major}-${release_minor}/${package_name}"
  }

  # full path to the installer
  $destination = "${destination_dir}${package_name}"
  notice ("Destination is ${destination}")

  case $package_type {
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
      $install_command = "tar -zxf ${destination} -C /usr/lib/jvm"
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
        cookie       => 'gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie',
        extract_path => '/tmp',
        cleanup      => false,
        creates      => $creates_path,
        proxy_server => $proxy_server,
        proxy_type   => $proxy_type,
      }
      case $facts['kernel'] {
        'Linux' : {
          exec { "Install Oracle java_se ${java_se} ${version}" :
            path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
            command => $install_command,
            creates => $creates_path,
            require => Archive[$destination]
          }
          case $facts['os']['family'] {
            'Debian' : {
              file{'/usr/lib/jvm':
                ensure => directory,
                before => Exec["Install Oracle java_se ${java_se} ${version}"]
              }
            }
            default : { }
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
