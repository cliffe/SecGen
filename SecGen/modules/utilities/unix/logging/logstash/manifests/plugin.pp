# Manage the installation of a Logstash plugin.
#
# By default, plugins are downloaded from RubyGems, but it is also possible
# to install from a local Gem, or one stored in Puppet.
#
# @example Install a plugin.
#   logstash::plugin { 'logstash-input-stdin': }
#
# @example Remove a plugin.
#   logstash::plugin { 'logstash-input-stout':
#     ensure => absent,
#   }
#
# @example Install a plugin from a local file.
#   logstash::plugin { 'logstash-input-custom':
#     source => 'file:///tmp/logstash-input-custom.gem',
#   }
#
# @example Install a plugin from a Puppet module.
#   logstash::plugin { 'logstash-input-custom':
#     source => 'puppet:///modules/logstash-site-plugins/logstash-input-custom.gem',
#   }
#
# @example Install X-Pack.
#   logstash::plugin { 'x-pack':
#     source => 'https://artifacts.elastic.co/downloads/packs/x-pack/x-pack-5.3.0.zip',
#   }
#
# @example Install a plugin, overriding JVM options via the environment.
#   logstash::plugin { 'logstash-input-jmx':
#     environment => ['LS_JVM_OPTIONS="-Xms1g -Xmx1g"']
#   }
#
# @param ensure [String] Install or remove with `present` or `absent`.
#
# @param source [String] Install from this file, not from RubyGems.
#
# @param environment [String] Environment used when running 'logstash-plugin'
#
define logstash::plugin (
  $source = undef,
  $ensure = present,
  $environment = [],
)
{
  require logstash::package
  $exe = "${logstash::home_dir}/bin/logstash-plugin"

  Exec {
    path        => '/bin:/usr/bin',
    cwd         => '/tmp',
    user        => $logstash::logstash_user,
    timeout     => 1800,
    environment => $environment,
  }

  case $source { # Where should we get the plugin from?
    undef: {
      # No explict source, so search Rubygems for the plugin, by name.
      # ie. "logstash-plugin install logstash-output-elasticsearch"
      $plugin = $name
    }

    /^(\/|file:)/: {
      # A gem file that is already available on the local filesystem.
      # Install from the local path.
      # ie. "logstash-plugin install /tmp/logtash-filter-custom.gem" or
      # "logstash-plugin install file:///tmp/logtash-filter-custom.gem" or
      $plugin = $source
    }

    /^puppet:/: {
      # A 'puppet:///' URL. Download the gem from Puppet, then install
      # the plugin from the downloaded file.
      $downloaded_file = sprintf('/tmp/%s', basename($source))
      file { $downloaded_file:
        source => $source,
        before => Exec["install-${name}"],
      }

      case $source {
        /\.zip$/: {
          $plugin = "file://${downloaded_file}"
        }
        default: {
          $plugin = $downloaded_file
        }
      }
    }

    /^https?:/: {
      # An 'http(s):///' URL.
      $plugin = $source
    }

    default: {
      fail('"source" should be a local path, a "puppet:///" url, or undef.')
    }
  }

  case $ensure {
    'present': {
      exec { "install-${name}":
        command => "${exe} install ${plugin}",
        unless  => "${exe} list ^${name}$",
      }
    }

    /^\d+\.\d+\.\d+/: {
      exec { "install-${name}":
        command => "${exe} install --version ${ensure} ${plugin}",
        unless  => "${exe} list --verbose ^${name}$ | grep --fixed-strings --quiet '(${ensure})'",
      }
    }

    'absent': {
      exec { "remove-${name}":
        command => "${exe} remove ${name}",
        onlyif  => "${exe} list | grep -q ^${name}$",
      }
    }

    default: {
      fail "'ensure' should be 'present', 'absent', or a version like '1.3.4'."
    }
  }
}
