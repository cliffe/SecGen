# == Class: docker::params
#
# Default parameter values for the docker module
#
class docker::params {
  $version                           = undef
  $ensure                            = present
  $docker_ce_start_command           = 'dockerd'
  $docker_ce_package_name            = 'docker-ce'
  $docker_engine_start_command       = 'docker daemon'
  $docker_engine_package_name        = 'docker-engine'
  $docker_ce_channel                 = stable
  $docker_ee                         = false
  $docker_ee_start_command           = 'dockerd'
  if ($::osfamily == 'windows') {
    $docker_ee_package_name          = 'Docker'
  } else {
    $docker_ee_package_name          = 'docker-ee'
  }
  $docker_ee_source_location         = undef
  $docker_ee_key_source              = undef
  $docker_ee_key_id                  = undef
  $docker_ee_repos                   = stable
  $tcp_bind                          = undef
  $tls_enable                        = false
  $tls_verify                        = true
  if ($::osfamily == 'windows') {
    $tls_cacert                        = 'C:/ProgramData/docker/certs.d/ca.pem'
    $tls_cert                          = 'C:/ProgramData/docker/certs.d/server-cert.pem'
    $tls_key                           = 'C:/ProgramData/docker/certs.d/server-key.pem'
    $compose_version                   = '1.21.2'
    $compose_install_path              = 'C:/Program Files/Docker'
  } else {
    $tls_cacert                        = '/etc/docker/tls/ca.pem'
    $tls_cert                          = '/etc/docker/tls/cert.pem'
    $tls_key                           = '/etc/docker/tls/key.pem'
    $compose_version                   = '1.9.0'
    $compose_install_path              = '/usr/local/bin'
  }
  $ip_forward                        = true
  $iptables                          = true
  $ipv6                              = false
  $ipv6_cidr                         = undef
  $default_gateway_ipv6              = undef
  $icc                               = undef
  $ip_masq                           = true
  $bip                               = undef
  $mtu                               = undef
  $fixed_cidr                        = undef
  $bridge                            = undef
  $default_gateway                   = undef
  $socket_bind                       = 'unix:///var/run/docker.sock'
  $log_level                         = undef
  $log_driver                        = undef
  $log_opt                           = []
  $selinux_enabled                   = undef
  $socket_group_default              = 'docker'
  $labels                            = []
  $service_state                     = running
  $service_enable                    = true
  $manage_service                    = true
  $root_dir                          = undef
  $tmp_dir_config                    = true
  $tmp_dir                           = '/tmp/'
  $dns                               = undef
  $dns_search                        = undef
  $proxy                             = undef
  $no_proxy                          = undef
  $execdriver                        = undef
  $storage_driver                    = undef
  $dm_basesize                       = undef
  $dm_fs                             = undef
  $dm_mkfsarg                        = undef
  $dm_mountopt                       = undef
  $dm_blocksize                      = undef
  $dm_loopdatasize                   = undef
  $dm_loopmetadatasize               = undef
  $dm_datadev                        = undef
  $dm_metadatadev                    = undef
  $dm_thinpooldev                    = undef
  $dm_use_deferred_removal           = undef
  $dm_use_deferred_deletion          = undef
  $dm_blkdiscard                     = undef
  $dm_override_udev_sync_check       = undef
  $overlay2_override_kernel_check    = false
  $manage_package                    = true
  $package_source                    = undef
  $docker_command                    = 'docker'
  $service_name_default              = 'docker'
  $docker_group_default              = 'docker'
  $storage_devs                      = undef
  $storage_vg                        = undef
  $storage_root_size                 = undef
  $storage_data_size                 = undef
  $storage_min_data_size             = undef
  $storage_chunk_size                = undef
  $storage_growpart                  = undef
  $storage_auto_extend_pool          = undef
  $storage_pool_autoextend_threshold = undef
  $storage_pool_autoextend_percent   = undef
  $storage_config_template           = 'docker/etc/sysconfig/docker-storage.erb'
  $registry_mirror                   = undef
  $os_lc                             = downcase($::operatingsystem)
  $docker_msft_provider_version      = undef
  $nuget_package_provider_version    = undef

  case $::osfamily {
    'Debian' : {
      case $::operatingsystem {
        'Ubuntu' : {
          $package_release = "ubuntu-${::lsbdistcodename}"
          if (versioncmp($::operatingsystemrelease, '15.04') >= 0) {
            $service_provider        = 'systemd'
            $storage_config          = '/etc/default/docker-storage'
            $service_config_template = 'docker/etc/sysconfig/docker.systemd.erb'
            $service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-debian.conf.erb'
            $service_hasstatus       = true
            $service_hasrestart      = true
            include docker::systemd_reload
          } else {
            $service_config_template = 'docker/etc/default/docker.erb'
            $service_overrides_template = undef
            $service_provider        = 'upstart'
            $service_hasstatus       = true
            $service_hasrestart      = false
            $storage_config          = undef
          }
        }
        default: {
          $package_release = "debian-${::lsbdistcodename}"
          $service_provider           = 'systemd'
          $storage_config             = '/etc/default/docker-storage'
          $service_config_template    = 'docker/etc/sysconfig/docker.systemd.erb'
          $service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-debian.conf.erb'
          $service_hasstatus          = true
          $service_hasrestart         = true
          include docker::systemd_reload
        }
      }

      $service_name = $service_name_default
      $docker_group = $docker_group_default
      $socket_group = $socket_group_default
      $use_upstream_package_source = true
      $pin_upstream_package_source = true
      $apt_source_pin_level = 10
      $repo_opt = undef
      $service_config = undef
      $storage_setup_file = undef

      $package_ce_source_location = "https://download.docker.com/linux/${os_lc}"
      $package_ce_key_source = "https://download.docker.com/linux/${os_lc}/gpg"
      $package_ce_key_id = '9DC858229FC7DD38854AE2D88D81803C0EBFCD88'
      $package_ce_release = $::lsbdistcodename
      $package_source_location = 'http://apt.dockerproject.org/repo'
      $package_key_source = 'https://apt.dockerproject.org/gpg'
      $package_key_check_source = undef
      $package_key_id = '58118E89F3A912897C070ADBF76221572C52609D'
      $package_ee_source_location = $docker_ee_source_location
      $package_ee_key_source = $docker_ee_key_source
      $package_ee_key_id = $docker_ee_key_id
      $package_ee_release = $::lsbdistcodename
      $package_ee_repos = $docker_ee_repos
      $package_ee_package_name = $docker_ee_package_name


      if ($service_provider == 'systemd') {
        $detach_service_in_init = false
      } else {
        $detach_service_in_init = true
      }

    }
    'RedHat' : {
      $service_config = '/etc/sysconfig/docker'
      $storage_config = '/etc/sysconfig/docker-storage'
      $storage_setup_file = '/etc/sysconfig/docker-storage-setup'
      $service_hasstatus  = true
      $service_hasrestart = true


      $service_provider           = 'systemd'
      $service_config_template    = 'docker/etc/sysconfig/docker.systemd.erb'
      $service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-rhel.conf.erb'
      $use_upstream_package_source = true

      $package_ce_source_location = "https://download.docker.com/linux/centos/${::operatingsystemmajrelease}/${::architecture}/${docker_ce_channel}"
      $package_ce_key_source = 'https://download.docker.com/linux/centos/gpg'
      $package_ce_key_id = undef
      $package_ce_release = undef
      $package_key_id = undef
      $package_release = undef
      $package_source_location = "https://yum.dockerproject.org/repo/main/centos/${::operatingsystemmajrelease}"
      $package_key_source = 'https://yum.dockerproject.org/gpg'
      $package_key_check_source = true
      $package_ee_source_location = $docker_ee_source_location
      $package_ee_key_source = $docker_ee_key_source
      $package_ee_key_id = $docker_ee_key_id
      $package_ee_release = undef
      $package_ee_repos = $docker_ee_repos
      $package_ee_package_name = $docker_ee_package_name
      $pin_upstream_package_source = undef
      $apt_source_pin_level = undef
      $service_name = $service_name_default
      $detach_service_in_init = false

      if $use_upstream_package_source {
        $docker_group = $docker_group_default
        $socket_group = $socket_group_default
      } else {
        $docker_group = 'dockerroot'
        $socket_group = 'dockerroot'
      }

      # repo_opt to specify install_options for docker package
      if $::operatingsystem == 'RedHat' {
        $repo_opt = '--enablerepo=rhel-7-server-extras-rpms'
      } else {
        $repo_opt = undef
      }
    }
    'windows' : {
      $msft_nuget_package_provider_version = $nuget_package_provider_version
      $msft_provider_version = $docker_msft_provider_version
      $msft_package_version = $version
      $service_config_template = 'docker/windows/config/daemon.json.erb'
      $service_config = 'C:/ProgramData/docker/config/daemon.json'
      $docker_group = 'docker'
      $package_ce_source_location = undef
      $package_ce_key_source = undef
      $package_ce_key_id = undef
      $package_ce_repos = undef
      $package_ce_release = undef
      $package_key_id = undef
      $package_release = undef
      $package_source_location = undef
      $package_key_source = undef
      $package_key_check_source = undef
      $package_ee_source_location = undef
      $package_ee_package_name = $docker_ee_package_name
      $package_ee_key_source = undef
      $package_ee_key_id = undef
      $package_ee_repos = undef
      $package_ee_release = undef
      $use_upstream_package_source = undef
      $pin_upstream_package_source = undef
      $apt_source_pin_level= undef
      $socket_group = undef
      $service_name = $service_name_default
      $repo_opt = undef
      $storage_config = undef
      $storage_setup_file = undef
      $service_provider = undef
      $service_overrides_template = undef
      $service_hasstatus = undef
      $service_hasrestart = undef
      $detach_service_in_init = true
    }
    default: {
      $docker_group = $docker_group_default
      $socket_group = $socket_group_default
      $package_key_source = undef
      $package_key_check_source = undef
      $package_source_location = undef
      $package_key_id = undef
      $package_repos = undef
      $package_release = undef
      $package_ce_key_source = undef
      $package_ce_source_location = undef
      $package_ce_key_id = undef
      $package_ce_repos = undef
      $package_ce_release = undef
      $package_ee_source_location = undef
      $package_ee_key_source = undef
      $package_ee_key_id = undef
      $package_ee_release = undef
      $package_ee_repos = undef
      $package_ee_package_name = undef
      $use_upstream_package_source = true
      $service_overrides_template = undef
      $service_hasstatus  = undef
      $service_hasrestart = undef
      $service_provider = undef
      $package_name = $docker_ce_package_name
      $service_name = $service_name_default
      $detach_service_in_init = true
      $repo_opt = undef
      $nowarn_kernel = false
      $service_config = undef
      $storage_config = undef
      $storage_setup_file = undef
      $service_config_template = undef
      $pin_upstream_package_source = undef
      $apt_source_pin_level = undef
    }
  }

  # Special extra packages are required on some OSes.
  # Specifically apparmor is needed for Ubuntu:
  # https://github.com/docker/docker/issues/4734
  $prerequired_packages = $::osfamily ? {
    'Debian' => $::operatingsystem ? {
      'Debian' => ['cgroupfs-mount'],
      'Ubuntu' => ['cgroup-lite', 'apparmor'],
      default  => [],
    },
    'RedHat' => ['device-mapper'],
    default  => [],
  }

}
