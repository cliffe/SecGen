require 'puppet/util/feature'
require 'puppet/util/package'

shield_plugin_dir = '/usr/share/elasticsearch/plugins/shield'

Puppet.features.add(:elasticsearch_shield_users_native) {
  File.exist? shield_plugin_dir and
    Dir[shield_plugin_dir + '/*.jar'].map do |file|
      File.basename(file, '.jar').split('-')
    end.select do |parts|
      parts.include? 'shield'
    end.any? do |parts|
      parts.last =~ /^[\d.]+$/ and
        Puppet::Util::Package.versioncmp(parts.last, '2.3') >= 0
    end
}
