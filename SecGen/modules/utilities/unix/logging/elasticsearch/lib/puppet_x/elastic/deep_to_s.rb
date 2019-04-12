module Puppet_X
  # Custom Elastic functions
  module Elastic
    # When given a hash, this method recurses deeply into all values to convert
    # any that aren't data structures into strings. This is necessary when
    # comparing results from Elasticsearch API calls, because values like
    # integers and booleans are in string form.
    def self.deep_to_s(obj)
      if obj.is_a? Array
        obj.map { |element| deep_to_s(element) }
      elsif obj.is_a? Hash
        obj.merge(obj) { |_key, val| deep_to_s(val) }
      elsif (not obj.is_a? String) and (not [true, false].include?(obj)) and obj.respond_to? :to_s
        obj.to_s
      else
        obj
      end
    end
  end # of Elastic
end # of Puppet_X
