$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet_x/elastic/asymmetric_compare'
require 'puppet_x/elastic/deep_to_i'
require 'puppet_x/elastic/deep_to_s'
require 'puppet_x/elastic/elasticsearch_rest_resource'

Puppet::Type.newtype(:elasticsearch_index) do
  extend ElasticsearchRESTResource

  desc 'Manages Elasticsearch index settings.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Index name.'
  end

  newproperty(:settings) do
    desc 'Structured settings for the index in hash form.'

    def insync?(is)
      Puppet_X::Elastic.asymmetric_compare(should, is)
    end

    munge do |value|
      Puppet_X::Elastic.deep_to_i(Puppet_X::Elastic.deep_to_s(value))
    end

    validate do |value|
      raise Puppet::Error, 'hash expected' unless value.is_a? Hash
    end
  end
end # of newtype
