$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet/provider/elastic_rest'

require 'puppet_x/elastic/deep_to_i'
require 'puppet_x/elastic/deep_to_s'

Puppet::Type.type(:elasticsearch_index).provide(
  :ruby,
  :parent => Puppet::Provider::ElasticREST,
  :metadata => :settings,
  :metadata_pipeline => [
    lambda { |data| data['settings'] },
    lambda { |data| Puppet_X::Elastic.deep_to_s data },
    lambda { |data| Puppet_X::Elastic.deep_to_i data }
  ],
  :api_uri => '_settings',
  :api_discovery_uri => '_all',
  :api_resource_style => :prefix,
  :discrete_resource_creation => true
) do
  desc 'A REST API based provider to manage Elasticsearch index settings.'

  mk_resource_methods
end
