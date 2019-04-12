require 'puppet/provider/elastic_rest'

Puppet::Type.type(:elasticsearch_license).provide(
  :shield,
  :api_resource_style => :bare,
  :parent => Puppet::Provider::ElasticREST,
  :metadata => :content,
  :metadata_pipeline => [
    lambda { |data| Puppet_X::Elastic.deep_to_s data },
    lambda { |data| Puppet_X::Elastic.deep_to_i data }
  ],
  :api_uri => '_license',
  :query_string => {
    'acknowledge' => 'true'
  }
) do
  desc 'A REST API based provider to manage Elasticsearch Shield licenses.'

  mk_resource_methods

  def self.process_body(body)
    JSON.parse(body).map do |_object_name, api_object|
      {
        :name     => name.to_s,
        :ensure   => :present,
        metadata  => { 'license' => process_metadata(api_object) },
        :provider => name
      }
    end
  end
end
