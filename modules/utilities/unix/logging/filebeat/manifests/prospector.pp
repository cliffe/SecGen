# filebeat::prospector
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   filebeat::prospector { 'namevar': }
define filebeat::prospector (
  Enum['absent', 'present'] $ensure = present,
  Array[String] $paths              = [],
  Array[String] $exclude_files      = [],
  String $encoding                  = 'plain',
  String $input_type                = 'log',
  Hash $fields                      = {},
  Boolean $fields_under_root        = false,
  Optional[String] $ignore_older    = undef,
  Optional[String] $close_older     = undef,
  String $doc_type                  = 'log',
  String $scan_frequency            = '10s',
  Integer $harvester_buffer_size    = 16384,
  Boolean $tail_files               = false,
  String $backoff                   = '1s',
  String $max_backoff               = '10s',
  Integer $backoff_factor           = 2,
  String $close_inactive            = '5m',
  Boolean $close_renamed            = false,
  Boolean $close_removed            = true,
  Boolean $close_eof                = false,
  Integer $clean_inactive           = 0,
  Boolean $clean_removed            = true,
  Integer $close_timeout            = 0,
  Boolean $force_close_files        = false,
  Array[String] $include_lines      = [],
  Array[String] $exclude_lines      = [],
  String $max_bytes                 = '10485760',
  Hash $multiline                   = {},
  Hash $json                        = {},
  Array[String] $tags               = [],
  Boolean $symlinks                 = false,
  Optional[String] $pipeline        = undef,
  Array $processors                 = [],
) {

  $prospector_template = $filebeat::major_version ? {
    '5'     => 'prospector5.yml.erb',
    default => 'prospector.yml.erb',
  }

  if $::filebeat_version {
    $skip_validation = versioncmp($::filebeat_version, $filebeat::major_version) ? {
      -1      => true,
      default => false,
    }
  } else {
    $skip_validation = false
  }

  case $::kernel {
    'Linux', 'OpenBSD' : {
      $validate_cmd = ($filebeat::disable_config_test or $skip_validation) ? {
        true    => undef,
        default => $filebeat::major_version ? {
          '5'     => "\"${filebeat::filebeat_path}\" -N -configtest -c \"%\"",
          default => "\"${filebeat::filebeat_path}\" -c \"${filebeat::config_file}\" test config",
        },
      }
      file { "filebeat-${name}":
        ensure       => $ensure,
        path         => "${filebeat::config_dir}/${name}.yml",
        owner        => 'root',
        group        => '0',
        mode         => $::filebeat::config_file_mode,
        content      => template("${module_name}/${prospector_template}"),
        validate_cmd => $validate_cmd,
        notify       => Service['filebeat'],
        before       => File['filebeat.yml'],
      }
    }

    'FreeBSD' : {
      $validate_cmd = ($filebeat::disable_config_test or $skip_validation) ? {
        true    => undef,
        default => '/usr/local/sbin/filebeat -N -configtest -c %',
      }
      file { "filebeat-${name}":
        ensure       => $ensure,
        path         => "${filebeat::config_dir}/${name}.yml",
        owner        => 'root',
        group        => 'wheel',
        mode         => $::filebeat::config_file_mode,
        content      => template("${module_name}/${prospector_template}"),
        validate_cmd => $validate_cmd,
        notify       => Service['filebeat'],
        before       => File['filebeat.yml'],
      }
    }

    'Windows' : {
      $cmd_install_dir = regsubst($filebeat::install_dir, '/', '\\', 'G')
      $filebeat_path = join([$cmd_install_dir, 'Filebeat', 'filebeat.exe'], '\\')

      $validate_cmd = ($filebeat::disable_config_test or $skip_validation) ? {
        true    => undef,
        default => $::filebeat_version ? {
          '5'     => "\"${filebeat_path}\" -N -configtest -c \"%\"",
          default => "\"${filebeat_path}\" -c \"${filebeat::config_file}\" test config",
        },
      }

      file { "filebeat-${name}":
        ensure       => $ensure,
        path         => "${filebeat::config_dir}/${name}.yml",
        content      => template("${module_name}/${prospector_template}"),
        validate_cmd => $validate_cmd,
        notify       => Service['filebeat'],
        before       => File['filebeat.yml'],
      }
    }

    default : {
      fail($filebeat::kernel_fail_message)
    }

  }
}
