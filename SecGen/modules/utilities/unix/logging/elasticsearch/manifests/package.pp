# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
# @example importing this class by other classes to use its functionality:
#   class { 'elasticsearch::package': }
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class elasticsearch::package {

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
    tries     => 3,
    try_sleep => 10,
  }

  if $elasticsearch::ensure == 'present' {

    if $elasticsearch::restart_package_change {
      Package['elasticsearch'] ~> Elasticsearch::Service <| |>
    }
    Package['elasticsearch'] ~> Exec['remove_plugin_dir']

    # Create directory to place the package file
    $package_dir = $elasticsearch::package_dir
    exec { 'create_package_dir_elasticsearch':
      cwd     => '/',
      path    => ['/usr/bin', '/bin'],
      command => "mkdir -p ${package_dir}",
      creates => $package_dir,
    }

    file { $package_dir:
      ensure  => 'directory',
      purge   => $elasticsearch::purge_package_dir,
      force   => $elasticsearch::purge_package_dir,
      backup  => false,
      require => Exec['create_package_dir_elasticsearch'],
    }

    # Check if we want to install a specific version or not
    if $elasticsearch::version == false {

      $package_ensure = $elasticsearch::autoupgrade ? {
        true  => 'latest',
        false => 'present',
      }

    } else {

      # install specific version
      $package_ensure = $elasticsearch::pkg_version

    }

    # action
    if ($elasticsearch::package_url != undef) {

      case $elasticsearch::package_provider {
        'package': { $before = Package['elasticsearch']  }
        default:   { fail("software provider \"${elasticsearch::package_provider}\".") }
      }


      $filename_array = split($elasticsearch::package_url, '/')
      $basefilename = $filename_array[-1]

      $source_array = split($elasticsearch::package_url, ':')
      $protocol_type = $source_array[0]

      $ext_array = split($basefilename, '\.')
      $ext = $ext_array[-1]

      $pkg_source = "${package_dir}/${basefilename}"

      case $protocol_type {

        'puppet': {

          file { $pkg_source:
            ensure  => file,
            source  => $elasticsearch::package_url,
            require => File[$package_dir],
            backup  => false,
            before  => $before,
          }

        }
        'ftp', 'https', 'http': {

          if $elasticsearch::proxy_url != undef {
            $exec_environment = [
              'use_proxy=yes',
              "http_proxy=${elasticsearch::proxy_url}",
              "https_proxy=${elasticsearch::proxy_url}",
            ]
          } else {
            $exec_environment = []
          }

          case $elasticsearch::download_tool {
            String: {
              $_download_command = if $elasticsearch::download_tool_verify_certificates {
                $elasticsearch::download_tool
              } else {
                $elasticsearch::download_tool_insecure
              }

              exec { 'download_package_elasticsearch':
                command     => "${_download_command} ${pkg_source} ${elasticsearch::package_url} 2> /dev/null",
                creates     => $pkg_source,
                environment => $exec_environment,
                timeout     => $elasticsearch::package_dl_timeout,
                require     => File[$package_dir],
                before      => $before,
              }
            }
            default: {
              fail("no \$elasticsearch::download_tool defined for ${facts['os']['family']}")
            }
          }

        }
        'file': {

          $source_path = $source_array[1]
          file { $pkg_source:
            ensure  => file,
            source  => $source_path,
            require => File[$package_dir],
            backup  => false,
            before  => $before,
          }

        }
        default: {
          fail("Protocol must be puppet, file, http, https, or ftp. You have given \"${protocol_type}\"")
        }
      }

      if ($elasticsearch::package_provider == 'package') {

        case $ext {
          'deb':   { Package { provider => 'dpkg', source => $pkg_source } }
          'rpm':   { Package { provider => 'rpm', source => $pkg_source } }
          default: { fail("Unknown file extention \"${ext}\".") }
        }

      }

    } else {
      if ($facts['os']['family'] == 'Debian') {
        Class['apt::update'] -> Package['elasticsearch']
      }
    }

  # Package removal
  } else {

    if ($facts['os']['family'] == 'Suse') {
      Package {
        provider  => 'rpm',
      }
      $package_ensure = 'absent'
    } else {
      $package_ensure = 'purged'
    }

  }

  if ($elasticsearch::package_provider == 'package') {

    package { 'elasticsearch':
      ensure => $package_ensure,
      name   => $elasticsearch::_package_name,
    }

    exec { 'remove_plugin_dir':
      refreshonly => true,
      command     => "rm -rf ${elasticsearch::plugindir}",
    }


  } else {
    fail("\"${elasticsearch::package_provider}\" is not supported")
  }

}
