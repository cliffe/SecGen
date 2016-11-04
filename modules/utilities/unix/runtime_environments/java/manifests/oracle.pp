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
# "http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jre-8u25-linux-x64.tar.gz"
#
# Parameters
# [*version*]
# Version of Java to install
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
# types have the rpms extracted and then foricibly installed. 'rpm' types are
# foricibly installed.
#
# [*url*]
# Full URL, including oracle_url, release_major, release_minor and package_name, to
# download the Oracle java_se installer.
#
# ### Author
# mike@marseglia.org
#
define java::oracle (
  $ensure       = 'present',
  $version      = '8',
  $java_se      = 'jdk',
  $oracle_url   = 'http://download.oracle.com/otn-pub/java/jdk/',
) {

  # archive module is used to download the java package
  include ::archive

  ensure_resource('class', 'stdlib')

  # validate java Standard Edition to download
  if $java_se !~ /(jre|jdk)/ {
    fail('Java SE must be either jre or jdk.')
  }

  # determine oracle Java major and minor version, and installation path
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
      $release_major = '8u51'
      $release_minor = 'b16'
      $install_path = "${java_se}1.8.0_51"
    }
    default : {
      $release_major = '8u51'
      $release_minor = 'b16'
      $install_path = "${java_se}1.8.0_51"
    }
  }

  # determine package type (exe/tar/rpm), destination directory based on OS
  case $::kernel {
    'Linux' : {
      case $::operatingsystem {
        'CentOS' : {
          # Oracle Java 6 comes in a special rpmbin format
          if $version == '6' {
            $package_type = 'rpmbin'
          } else {
            $package_type = 'rpm'
          }
        }
        default : {
          fail ("unsupported platform ${::operatingsystem}") }
      }

      $os = 'linux'
      $destination_dir = '/tmp/'
      $creates_path = "/usr/java/${install_path}"
    }
    default : {
      fail ( "unsupported platform ${::kernel}" ) }
  }

  # set java architecture nomenclature
  case $::architecture {
    'i386' : { $arch = 'i586' }
    'x86_64' : { $arch = 'x64' }
    default : {
      fail ("unsupported platform ${::architecture}")
    }
  }

  # following are based on this example:
  # http://download.oracle.com/otn/java/jdk/7u80-b15/jre-7u80-linux-i586.rpm
  #
  # JaveSE 6 distributed in .bin format
  # http://download.oracle.com/otn/java/jdk/6u45-b06/jdk-6u45-linux-i586-rpm.bin
  # http://download.oracle.com/otn/java/jdk/6u45-b06/jdk-6u45-linux-i586.bin
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
    default : {
      $package_name = "${java_se}-${release_major}-${os}-${arch}.rpm"
    }
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
    default : {
      $install_command = "rpm -iv ${destination}"
    }
  }

  case $ensure {
    'present' : {
      archive { $destination :
        ensure  => present,
        source  => "${oracle_url}${release_major}-${release_minor}/${package_name}",
        cleanup => false,
        cookie  => 'gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie',
      }->
      case $::kernel {
        'Linux' : {
          exec { "Install Oracle java_se ${java_se} ${version}" :
            path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
            command => $install_command,
            creates => $creates_path,
          }
        }
        default : {
          fail ("unsupported platform ${::kernel}")
        }
      }
    }
    default : {
      notice ("Action ${ensure} not supported.")
    }
  }

}
