require 'puppet/provider/elastic_plugin'

Puppet::Type.type(:elasticsearch_plugin).provide(
  :plugin,
  :parent => Puppet::Provider::ElasticPlugin
) do
  desc 'Pre-5.x provider for Elasticsearch bin/plugin command operations.'

  case Facter.value('osfamily')
  when 'OpenBSD'
    commands :plugin => '/usr/local/elasticsearch/bin/plugin'
    commands :es => '/usr/local/elasticsearch/bin/elasticsearch'
    commands :javapathhelper => '/usr/local/bin/javaPathHelper'
  else
    commands :plugin => '/usr/share/elasticsearch/bin/plugin'
    commands :es => '/usr/share/elasticsearch/bin/elasticsearch'
  end
end
