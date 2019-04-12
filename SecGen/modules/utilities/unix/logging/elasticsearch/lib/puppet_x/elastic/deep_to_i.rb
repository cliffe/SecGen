module Puppet_X
  # Custom Elastic functions
  module Elastic
    # This ugly hack is required due to the fact Puppet passes in the
    # puppet-native hash with stringified numerics, which causes the
    # decoded JSON from the Elasticsearch API to be seen as out-of-sync
    # when the parsed template hash is compared against the puppet hash.
    def self.deep_to_i(obj)
      if obj.is_a? String and obj =~ /^-?[0-9]+$/
        obj.to_i
      elsif obj.is_a? Array
        obj.map { |element| deep_to_i(element) }
      elsif obj.is_a? Hash
        obj.merge(obj) { |_key, val| deep_to_i(val) }
      else
        obj
      end
    end
  end # of Elastic
end # of Puppet_X
