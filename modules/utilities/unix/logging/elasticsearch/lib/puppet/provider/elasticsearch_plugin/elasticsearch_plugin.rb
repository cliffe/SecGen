require 'puppet/provider/elastic_plugin'

Puppet::Type.type(:elasticsearch_plugin).provide(
  :elasticsearch_plugin,
  :parent => Puppet::Provider::ElasticPlugin
) do
  desc <<-END
    Post-5.x provider for Elasticsearch bin/elasticsearch-plugin
    command operations.'
  END

  case Facter.value('osfamily')
  when 'OpenBSD'
    commands :plugin => '/usr/local/elasticsearch/bin/elasticsearch-plugin'
    commands :es => '/usr/local/elasticsearch/bin/elasticsearch'
    commands :javapathhelper => '/usr/local/bin/javaPathHelper'
  else
    commands :plugin => '/usr/share/elasticsearch/bin/elasticsearch-plugin'
    commands :es => '/usr/share/elasticsearch/bin/elasticsearch'
  end
end
