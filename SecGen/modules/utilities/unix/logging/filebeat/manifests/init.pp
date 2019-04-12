# This class installs the Elastic filebeat log shipper and
# helps manage which files are shipped
#
# @example
# class { 'filebeat':
#   outputs => {
#     'logstash' => {
#       'hosts' => [
#         'localhost:5044',
#       ],
#     },
#   },
# }
#
# @param package_ensure [String] The ensure parameter for the filebeat package (default: present)
# @param manage_repo [Boolean] Whether or not the upstream (elastic) repo should be configured or not (default: true)
# @param major_version [Enum] The major version of Filebeat to be installed.
# @param service_ensure [String] The ensure parameter on the filebeat service (default: running)
# @param service_enable [String] The enable parameter on the filebeat service (default: true)
# @param repo_priority [Integer] Repository priority.  yum and apt supported (default: undef)
# @param spool_size [Integer] How large the spool should grow before being flushed to the network (default: 2048)
# @param idle_timeout [String] How often the spooler should be flushed even if spool size isn't reached (default: 5s)
# @param publish_async [Boolean] If set to true filebeat will publish while preparing the next batch of lines to send (defualt: false)
# @param registry_file [String] The registry file used to store positions, absolute or relative to working directory (default .filebeat)
# @param config_dir [String] The directory where prospectors should be defined (default: /etc/filebeat/conf.d)
# @param config_dir_mode [String] The unix permissions mode set on the configuration directory (default: 0755)
# @param config_file_mode [String] The unix permissions mode set on configuration files (default: 0644)
# @param purge_conf_dir [Boolean] Should files in the prospector configuration directory not managed by puppet be automatically purged
# @param outputs [Hash] Will be converted to YAML for the required outputs section of the configuration (see documentation, and above)
# @param shipper [Hash] Will be converted to YAML to create the optional shipper section of the filebeat config (see documentation)
# @param logging [Hash] Will be converted to YAML to create the optional logging section of the filebeat config (see documentation)
# @param modules [Array] Will be converted to YAML to create the optional modules section of the filebeat config (see documentation)
# @param conf_template [String] The configuration template to use to generate the main filebeat.yml config file
# @param download_url [String] The URL of the zip file that should be downloaded to install filebeat (windows only)
# @param install_dir [String] Where filebeat should be installed (windows only)
# @param tmp_dir [String] Where filebeat should be temporarily downloaded to so it can be installed (windows only)
# @param shutdown_timeout [String] How long filebeat waits on shutdown for the publisher to finish sending events
# @param beat_name [String] The name of the beat shipper (default: hostname)
# @param tags [Array] A list of tags that will be included with each published transaction
# @param queue_size [String] The internal queue size for events in the pipeline
# @param max_procs [Integer] The maximum number of CPUs that can be simultaneously used
# @param fields [Hash] Optional fields that should be added to each event output
# @param fields_under_root [Boolean] If set to true, custom fields are stored in the top level instead of under fields
# @param processors [Array] Processors that will be added. Commonly used to create processors using hiera.
# @param prospectors [Hash] Prospectors that will be created. Commonly used to create prospectors using hiera
# @param setup [Hash] setup that will be created. Commonly used to create setup using hiera
# @param prospectors_merge [Boolean] Whether $prospectors should merge all hiera sources, or use simple automatic parameter lookup
# proxy_address [String] Proxy server to use for downloading files
# @param xpack [Hash] Configuration items to export internal stats to a monitoring Elasticsearch cluster
class filebeat (
  String  $package_ensure                                             = $filebeat::params::package_ensure,
  Boolean $manage_repo                                                = $filebeat::params::manage_repo,
  Enum['5','6'] $major_version                                        = $filebeat::params::major_version,
  Variant[Boolean, Enum['stopped', 'running']] $service_ensure        = $filebeat::params::service_ensure,
  Boolean $service_enable                                             = $filebeat::params::service_enable,
  Optional[String]  $service_provider                                 = $filebeat::params::service_provider,
  Optional[Integer] $repo_priority                                    = undef,
  Integer $spool_size                                                 = $filebeat::params::spool_size,
  String  $idle_timeout                                               = $filebeat::params::idle_timeout,
  Boolean $publish_async                                              = $filebeat::params::publish_async,
  String  $registry_file                                              = $filebeat::params::registry_file,
  String  $config_file                                                = $filebeat::params::config_file,
  Optional[String] $config_file_owner                                 = $filebeat::params::config_file_owner,
  Optional[String] $config_file_group                                 = $filebeat::params::config_file_group,
  String[4,4]  $config_dir_mode                                       = $filebeat::params::config_dir_mode,
  String  $config_dir                                                 = $filebeat::params::config_dir,
  String[4,4]  $config_file_mode                                      = $filebeat::params::config_file_mode,
  Optional[String] $config_dir_owner                                  = $filebeat::params::config_dir_owner,
  Optional[String] $config_dir_group                                  = $filebeat::params::config_dir_group,
  Boolean $purge_conf_dir                                             = $filebeat::params::purge_conf_dir,
  Hash    $outputs                                                    = $filebeat::params::outputs,
  Hash    $shipper                                                    = $filebeat::params::shipper,
  Hash    $logging                                                    = $filebeat::params::logging,
  Hash    $run_options                                                = $filebeat::params::run_options,
  String  $conf_template                                              = $filebeat::params::conf_template,
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $download_url  = undef, # lint:ignore:140chars
  Optional[String]  $install_dir                                      = $filebeat::params::install_dir,
  String  $tmp_dir                                                    = $filebeat::params::tmp_dir,
  String  $shutdown_timeout                                           = $filebeat::params::shutdown_timeout,
  String  $beat_name                                                  = $filebeat::params::beat_name,
  Array   $tags                                                       = $filebeat::params::tags,
  Integer $queue_size                                                 = $filebeat::params::queue_size,
  Optional[Integer] $max_procs                                        = $filebeat::params::max_procs,
  Hash $fields                                                        = $filebeat::params::fields,
  Boolean $fields_under_root                                          = $filebeat::params::fields_under_root,
  Boolean $disable_config_test                                        = $filebeat::params::disable_config_test,
  Array   $processors                                                 = [],
  Hash    $prospectors                                                = {},
  Hash    $setup                                                      = {},
  Array   $modules                                                    = [],
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $proxy_address = undef, # lint:ignore:140chars
  Stdlib::Absolutepath $filebeat_path                                 = $filebeat::params::filebeat_path,
  Optional[Hash] $xpack                                               = $filebeat::params::xpack,
) inherits filebeat::params {

  include ::stdlib

  $real_download_url = $download_url ? {
    undef   => "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${package_ensure}-windows-${filebeat::params::url_arch}.zip",
    default => $download_url,
  }

  if $config_file != $filebeat::params::config_file {
    warning('You\'ve specified a non-standard config_file location - filebeat may fail to start unless you\'re doing something to fix this')
  }

  if $package_ensure == 'absent' {
    $alternate_ensure = 'absent'
    $real_service_ensure = 'stopped'
    $file_ensure = 'absent'
    $directory_ensure = 'absent'
  } else {
    $alternate_ensure = 'present'
    $file_ensure = 'file'
    $directory_ensure = 'directory'
    $real_service_ensure = $service_ensure
  }

  # If we're removing filebeat, do things in a different order to make sure
  # we remove as much as possible
  if $package_ensure == 'absent' {
    anchor { 'filebeat::begin': }
    -> class { '::filebeat::config': }
    -> class { '::filebeat::install': }
    -> class { '::filebeat::service': }
    -> anchor { 'filebeat::end': }
  } else {
    anchor { 'filebeat::begin': }
    -> class { '::filebeat::install': }
    -> class { '::filebeat::config': }
    -> class { '::filebeat::service': }
    -> anchor { 'filebeat::end': }
  }

  if $package_ensure != 'absent' {
    if !empty($prospectors) {
      create_resources('filebeat::prospector', $prospectors)
    }
  }
}
