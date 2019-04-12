# This class manages installation, configuration and execution of Logstash 5.x.
#
# @param [String] ensure
#   Controls if Logstash should be `present` or `absent`.
#
#   If set to `absent`, the Logstash package will be
#   uninstalled. Related files will be purged as much as possible. The
#   exact behavior is dependant on the service provider, specifically its
#   support for the 'purgable' property.
#
# @param [Boolean] auto_upgrade
#   If set to `true`, Logstash will be upgraded if the package provider is
#   able to find a newer version.  The exact behavior is dependant on the
#   service provider, specifically its support for the 'upgradeable' property.
#
# @param [String] status
#   The desired state of the Logstash service. Possible values:
#
#   - `enabled`: Service running and started at boot time.
#   - `disabled`: Service stopped and not started at boot time.
#   - `running`: Service running but not be started at boot time.
#   - `unmanaged`: Service will not be started at boot time. Puppet
#      will neither stop nor start the service.
#
# @param [String] version
#   The specific version to install, if desired.
#
# @param [Boolean] restart_on_change
#   Restart the service whenever the configuration changes.
#
#   Disabling automatic restarts on config changes may be desired in an
#   environment where you need to ensure restarts occur in a
#   controlled/rolling manner rather than during a Puppet run.
#
# @param [String] package_url
#   Explict Logstash package URL to download.
#
#   Valid URL types are:
#   - `http://`
#   - `https://`
#   - `ftp://`
#   - `puppet://`
#   - `file:/`
#
# @param [String] package_name
#   The name of the Logstash package in the package manager.
#
# @param [Integer] download_timeout
#   Timeout, in seconds, for http, https, and ftp downloads.
#
# @param [String] logstash_user
#   The user that Logstash should run as. This also controls file ownership.
#
# @param [String] logstash_group
#   The group that Logstash should run as. This also controls file group ownership.
#
# @param [Boolean] purge_config
#   Purge the config directory of any unmanaged files,
#
# @param [String] service_provider
#   Service provider (init system) to use. By Default, the module will try to
#   choose the 'standard' provider for the current distribution.
#
# @param [Hash] settings
#   A collection of settings to be defined in `logstash.yml`.
#
#   See: https://www.elastic.co/guide/en/logstash/current/logstash-settings-file.html
#
# @param [Hash] startup_options
#   A collection of settings to be defined in `startup.options`.
#
#   See: https://www.elastic.co/guide/en/logstash/current/config-setting-files.html
#
# @param [Array] jvm_options
#   A collection of settings to be defined in `jvm.options`.
#
# @param [Array] pipelines
#   A collection of settings to be defined in `pipelines.yml`.
#
# @param [Boolean] manage_repo
#   Enable repository management. Configure the official repositories.
#
# @param [String] config_dir
#   Path containing the Logstash configuration.
#
# @example Install Logstash, ensure the service is running and enabled.
#   class { 'logstash': }
#
# @example Remove Logstash.
#   class { 'logstash':
#     ensure => 'absent',
#   }
#
# @example Install everything but disable the service.
#   class { 'logstash':
#     status => 'disabled',
#   }
#
# @example Configure Logstash settings.
#   class { 'logstash':
#     settings => {
#       'http.port' => '9700',
#     }
#   }
#
# @example Configure Logstash startup options.
#   class { 'logstash':
#     startup_options => {
#       'LS_USER' => 'root',
#     }
#   }
#
# @example Set JVM memory options.
#   class { 'logstash':
#     jvm_options => [
#       '-Xms1g',
#       '-Xmx1g',
#     ]
#   }
#
# @example Configure multiple pipelines.
#   class { 'logstash':
#     pipelines => [
#       {
#         "pipeline.id" => "my-pipeline_1",
#         "path.config" =>  "/etc/path/to/p1.config",
#       },
#       {
#         "pipeline.id" => "my-other-pipeline",
#         "path.config" =>  "/etc/different/path/p2.cfg",
#       }
#     ]
#   }
#
# @author https://github.com/elastic/puppet-logstash/graphs/contributors
#
class logstash(
  $ensure            = 'present',
  $status            = 'enabled',
  Boolean $restart_on_change = true,
  Boolean $auto_upgrade       = false,
  $version           = undef,
  $package_url       = undef,
  $package_name      = 'logstash',
  Integer $download_timeout  = 600,
  $logstash_user     = 'logstash',
  $logstash_group    = 'logstash',
  $config_dir         = '/etc/logstash',
  Boolean $purge_config = true,
  $service_provider  = undef,
  $settings          = {},
  $startup_options   = {},
  $jvm_options       = [],
  Array $pipelines   = [],
  Boolean $manage_repo   = true,
)
{
  $home_dir = '/usr/share/logstash'

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  if ! ($status in [ 'enabled', 'disabled', 'running', 'unmanaged' ]) {
    fail("\"${status}\" is not a valid status parameter value")
  }

  if ($manage_repo == true) {
    include elastic_stack::repo
  }
  include logstash::package
  include logstash::config
  include logstash::service
}
