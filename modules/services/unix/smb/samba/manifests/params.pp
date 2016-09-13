# Class: samba::params
#
# This class defines default parameters used by the main module class samba
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to samba class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class samba::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'samba',
  }

  $service = $::operatingsystem ? {
    /(?i:Centos|RedHat|Scientific|Fedora|Amazon|Linux)/ => 'smb',
    /(?i:SLES|OpenSuSE)/                                => 'smb',
    /(?i:Ubuntu|Mint)/                                  => 'smbd',
    /(?i:Debian)/                                       => 'samba',
    default                                             => 'smb',
  }

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'smbd',
  }

  $process_args = $::operatingsystem ? {
    default => '',
  }

  $process_user = $::operatingsystem ? {
    default => 'root',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/samba',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/samba/smb.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/etc/default/samba',
    default                   => '/etc/sysconfig/samba',
  }

  $pid_file = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/var/run/samba/smbd.pid',
    default                   => '/var/run/smbd.pid',
  }

  $data_dir = $::operatingsystem ? {
    default => '/etc/samba',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/samba',
  }

  $log_file = $::operatingsystem ? {
    default => [ '/var/log/samba/log.smbd','/var/log/samba/log.nmbd' ],
  }

  $port = '445'
  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = ''
  $options = ''
  $service_autorestart = true
  $version = 'present'
  $absent = false
  $disable = false
  $disableboot = false

  ### General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = $::ipaddress
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false

}
