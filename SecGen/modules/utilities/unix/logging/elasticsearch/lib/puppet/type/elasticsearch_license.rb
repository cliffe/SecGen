$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet_x/elastic/asymmetric_compare'
require 'puppet_x/elastic/deep_to_i'
require 'puppet_x/elastic/deep_to_s'
require 'puppet_x/elastic/elasticsearch_rest_resource'

Puppet::Type.newtype(:elasticsearch_license) do
  extend ElasticsearchRESTResource

  desc 'Manages Elasticsearch licenses.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Pipeline name.'
  end

  newproperty(:content) do
    desc 'Structured hash for license content data.'

    def insync?(is)
      Puppet_X::Elastic.asymmetric_compare(
        should.map { |k, v| [k, v.is_a?(Hash) ? (v.reject { |s, _| s == 'signature' }) : v] }.to_h,
        is
      )
    end

    def should_to_s(newvalue)
      newvalue.map do |license, license_data|
        [
          license,
          if license_data.is_a? Hash
            license_data.map do |field, value|
              [field, field == 'signature' ? '[redacted]' : value]
            end.to_h
          else
            v
          end
        ]
      end.to_h.to_s
    end

    validate do |value|
      raise Puppet::Error, 'hash expected' unless value.is_a? Hash
    end

    munge do |value|
      Puppet_X::Elastic.deep_to_i(Puppet_X::Elastic.deep_to_s(value))
    end
  end
end # of newtype
