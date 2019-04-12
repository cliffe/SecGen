require 'puppet/provider/parsedfile'

# Parent class for Elasticsearch-based providers that need to access
# specific configuration directories.
class Puppet::Provider::ElasticParsedFile < Puppet::Provider::ParsedFile
  # Find/set a shield configuration file.
  #
  # @return String
  def self.shield_config(val)
    @default_target ||= "/etc/elasticsearch/shield/#{val}"
  end

  # Find/set an x-pack configuration file.
  #
  # @return String
  def self.xpack_config(val)
    @default_target ||= "/etc/elasticsearch/x-pack/#{val}"
  end

  # Find/set an oss x-pack configuration file.
  #
  # @return String
  def self.oss_xpack_config(val)
    @default_target ||= "/etc/elasticsearch/#{val}"
  end
end
