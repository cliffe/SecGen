# Defined Type java::sap
#
# @summary
#   Install one or more versions of SAPJVM or Sapmachine
#
# @param ensure
#   Install or remove the package.
#
# @param version
#   Version of Java to install, e.g. '8' or '9'. Default values for full versions will be used.
#
# @param version_full
#   Major version which should be installed, e.g. '8.1.063' or '11.0.7'. If used, "version" parameter is ignored.
#
# @param java
#   Type of Java Edition to install, jdk or jre.
#
# @param proxy_server
#   Specify a proxy server, with port number if needed. ie: https://example.com:8080. (passed to archive)
#
# @param proxy_type
#   Proxy server type (none|http|https|ftp). (passed to archive)
#
# @param basedir
#   Directory under which the installation will occur. If not set, defaults to
#   /usr/lib/jvm for Debian and /usr/java for RedHat.
#
# @param manage_basedir
#   Whether to manage the basedir directory.  Defaults to false.
#   Note: /usr/lib/jvm is managed for Debian by default, separate from this parameter.
#
# @param manage_symlink
#   Whether to manage a symlink that points to the installation directory.  Defaults to false.
#
# @param symlink_name
#   The name for the optional symlink in the installation directory.
#
define java::sap (
  $ensure         = 'present',
  $version        = '8',
  $version_full   = undef,
  $java           = 'jdk',
  $proxy_server   = undef,
  $proxy_type     = undef,
  $basedir        = undef,
  $manage_basedir = true,
  $manage_symlink = false,
  $symlink_name   = undef,
) {

  # archive module is used to download the java package
  include ::archive

  # validate java edition to download
  if $java !~ /(jre|jdk)/ {
    fail('java must be either jre or jdk.')
  }

  # determine version and installation path
  if $version_full {

    $_version_array = $version_full.scanf('%i')
    $_version_int = $_version_array[0]

    $_version_full = $version_full

  } else {
    $_version = $version
    $_version_int = Numeric($_version)
    # use default versions if full version parameter is not provided
    case $version {
      '7' : {
        $_version_full = '7.1.072'
        if ($java != 'jdk') {
          fail('java parameter is not jdk. jre is not supported on version 7')
        }
      }
      '8' : {
        $_version_full = '8.1.065'
        if ($java != 'jdk') {
          fail('java parameter is not jdk. jre is not supported on version 8')
        }
      }
      '11' : {
        $_version_full = '11.0.7'
      }
      '14' : {
        $_version_full = '14.0.1'
      }
      default : {
        fail("${version} not yet supported by module")
      }
    }
  }

  # extracted folders look like this:
  #  sapjvm_8
  #  sapmachine-jdk-11.0.7
  if ($_version_int == 7 or $_version_int == 8) {
    $_creates_folder = "sapjvm_${_version_int}"
  } else {
    $_creates_folder = "sapmachine-${java}-${_version_full}"
  }

  # determine destination directory based on OS
  case $facts['kernel'] {
    'Linux' : {
      case $facts['os']['family'] {
        'RedHat', 'Amazon' : {
          if $basedir {
            $_basedir = $basedir
          } else {
            $_basedir = '/usr/java'
          }
        }
        'Debian' : {
          if $basedir {
            $_basedir = $basedir
          } else {
            $_basedir = '/usr/lib/jvm'
          }
        }
        default : {
          fail ("unsupported os family ${$facts['os']['name']}") }
      }

      $creates_path = "${_basedir}/${_creates_folder}"
    }
    default : {
      fail ( "unsupported platform ${$facts['kernel']}" ) }
  }

  $_os_architecture = $facts['os']['architecture'] ? {
    undef => $facts['architecture'],
    default => $facts['os']['architecture']
  }

  if ($_os_architecture != 'x86_64' and $_os_architecture != 'amd64') {
    fail ("unsupported platform ${_os_architecture}")
  }

  # download links look like this (examples):
  # https://tools.hana.ondemand.com/additional/sapjvm-8.1.065-linux-x64.zip
  # https://github.com/SAP/SapMachine/releases/download/sapmachine-11.0.7/sapmachine-jre-11.0.7_linux-x64_bin.tar.gz
  # https://github.com/SAP/SapMachine/releases/download/sapmachine-11.0.7/sapmachine-jdk-11.0.7_linux-x64_bin.tar.gz
  # https://github.com/SAP/SapMachine/releases/download/sapmachine-14.0.1/sapmachine-jdk-14.0.1_linux-x64_bin.tar.gz

  # cookie is currently at version 3.1, but may be changed one day. It is only required for download at SAP.
  # by using this module you agree with the EULA presented at tools.hana.ondemand.com download page!
  # Github does not require it

  if ( $_version_int == 7 or $_version_int == 8 ) {
    # sapjvm download
    $archive_filename = "sapjvm-${_version_full}-linux-x64.zip"
    $source = "https://tools.hana.ondemand.com/additional/${archive_filename}"
    $cookie = 'eula_3_1_agreed=tools.hana.ondemand.com/developer-license-3_1.txt'

    if (!defined(Package['unzip'])) {
      package { 'unzip':
        ensure => 'present',
        before => Archive["/tmp/${archive_filename}"],
      }
    }
  } else {
    $archive_filename = "sapmachine-${java}-${_version_full}_linux-x64_bin.tar.gz"
    $source = "https://github.com/SAP/SapMachine/releases/download/sapmachine-${_version_full}/${archive_filename}"
    $cookie = undef

    if (!defined(Package['tar'])) {
      package { 'tar':
        ensure => 'present',
        before => Archive["/tmp/${archive_filename}"],
      }
    }
    if (!defined(Package['gzip'])) {
      package { 'gzip':
        ensure => 'present',
        before => Archive["/tmp/${archive_filename}"],
      }
    }
  }

  case $ensure {
    'present' : {
      case $facts['kernel'] {
        'Linux' : {
          if ($manage_basedir or $facts['os']['family'] == 'Debian'){
            if (!defined(File[$_basedir])) {
              file { $_basedir:
                ensure => 'directory',
                before => Archive["/tmp/${archive_filename}"],
              }
            }
          }

          archive { "/tmp/${archive_filename}" :
            ensure       => present,
            source       => $source,
            extract      => true,
            extract_path => $_basedir,
            cleanup      => false,
            creates      => $creates_path,
            cookie       => $cookie,
            proxy_server => $proxy_server,
            proxy_type   => $proxy_type,
          }

          if ($manage_symlink and $symlink_name) {
            file { "${_basedir}/${symlink_name}":
              ensure  => link,
              target  => $creates_path,
              require => Archive["/tmp/${archive_filename}"],
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
