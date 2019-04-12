# This class manages configuration directories for Logstash.
#
# @example Include this class to ensure its resources are available.
#   include logstash::config
#
# @author https://github.com/elastic/puppet-logstash/graphs/contributors
#
class logstash::config {
  require logstash::package

  File {
    owner => 'root',
    group => 'root',
  }

  # Configuration "fragment" directories for pipeline config and pattern files.
  # We'll keep these seperate since we may want to "purge" them. It's easy to
  # end up with orphan files when managing config fragments with Puppet.
  # Purging the directories resolves the problem.

  if($logstash::ensure == 'present') {
    file { $logstash::config_dir:
      ensure => directory,
      mode   => '0755',
    }

    file { "${logstash::config_dir}/conf.d":
      ensure  => directory,
      purge   => $logstash::purge_config,
      recurse => $logstash::purge_config,
      mode    => '0775',
      notify  => Service['logstash'],
    }

    file {     "${logstash::config_dir}/patterns":
      ensure  => directory,
      purge   => $logstash::purge_config,
      recurse => $logstash::purge_config,
      mode    => '0755',
    }
  }
  elsif($logstash::ensure == 'absent') {
    # Completely remove the config directory. ie. 'rm -rf /etc/logstash'
    file { $logstash::config_dir:
      ensure  => 'absent',
      recurse => true,
      force   => true,
    }
  }
}
