# This type represents a Logstash pipeline configuration file.
#
# Parameters are mutually exclusive. Only one should be specified.
#
# @param [String] content
#  Literal content to be placed in the file.
#
# @param [String] template
#  A template from which to render the file.
#
# @param [String] source
#  A file resource to be used for the file.
#
# @param [String] path
#  An optional full path at which to create the file.
#
# @example Create a config file content with literal content.
#
#   logstash::configfile { 'heartbeat':
#     content => 'input { heartbeat {} }',
#   }
#
# @example Render a config file from a template.
#
#   logstash::configfile { 'from-template':
#     template => 'site-logstash-module/pipeline-config.erb',
#   }
#
# @example Copy the config from a file source.
#
#   logstash::configfile { 'apache':
#     source => 'puppet://path/to/apache.conf',
#   }
#
# @example Create a config at specific location. Good for multiple pipelines.
#
#   logstash::configfile { 'heartbeat-2':
#     content => 'input { heartbeat {} }',
#     path    => '/usr/local/etc/logstash/pipeline-2/heartbeat.conf'
#   }
#
# @author https://github.com/elastic/puppet-logstash/graphs/contributors
#
define logstash::configfile(
  $content = undef,
  $source = undef,
  $template = undef,
  $path = undef,
)
{
  include logstash

  $owner = 'root'
  $group = $logstash::logstash_group
  $mode  = '0640'
  $require = Package['logstash'] # So that we have '/etc/logstash/conf.d'.
  $tag = [ 'logstash_config' ] # So that we notify the service.

  if($template)   { $config = template($template) }
  elsif($content) { $config = $content }
  else            { $config = undef }

  if($path) { $config_file = $path }
  else      { $config_file = "${logstash::config_dir}/conf.d/${name}" }

  if($config) {
    file { $config_file:
      content => $config,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      require => $require,
      tag     => $tag,
    }
  }
  elsif($source) {
    file { $config_file:
      source  => $source,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      require => $require,
      tag     => $tag,
    }
  }
}
