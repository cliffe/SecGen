module Puppet_X
  # Custom ruby for some Elastic utilities.
  module Elastic
    # Recursively implode a hash into dot-delimited structure of Hash
    # keys/values.
    def self.deep_implode(hash)
      ret = {}
      implode ret, hash
      ret
    end

    # Recursively descend into hash values, flattening the key structure into
    # dot-delimited keyed Hash.
    def self.implode(new_hash, hash, path = [])
      hash.sort_by { |k, _v| k.length }.reverse.each do |key, value|
        new_path = path + [key]
        case value
        when Hash
          implode(new_hash, value, new_path)
        else
          new_key = new_path.join('.')
          if value.is_a? Array \
              and new_hash.key? new_key \
              and new_hash[new_key].is_a? Array
            new_hash[new_key] += value
          else
            new_hash[new_key] ||= value
          end
        end
      end
    end # of deep_implode
  end # of Elastic
end # of Puppet_X
