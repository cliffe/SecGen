$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet_x/elastic/deep_implode'

# Top-level Puppet functions
module Puppet::Parser::Functions
  newfunction(
    :deep_implode,
    :type => :rvalue,
    :doc => <<-'ENDHEREDOC') do |args|
    Recursively flattens all keys of a hash into a dot-notated
    hash, deeply merging duplicate key values by natively combining
    them and returns the resulting hash.

    That is confusing, look at the examples for more clarity.

    For example:

        $hash = {'top' => {'sub' => [1]}, 'top.sub' => [2] }
        $flattened_hash = deep_implode($hash)
        # The resulting hash is equivalent to:
        # { 'top.sub' => [1, 2] }

    When the function encounters array or hash values, they are
    concatenated or merged, respectively.
    When duplace paths for a key are generated, the function will prefer
    to retain keys with the longest root key.

    @return Hash
    ENDHEREDOC

    if args.length != 1
      raise Puppet::ParseError, "deep_implode(): wrong number of arguments (#{args.length}; must be 1)"
    end

    arg = args[0]

    unless arg.is_a? Hash
      raise Puppet::ParseError, 'deep_implode: unexpected argument type, only expects hashes'
    end

    return {} if arg.empty?

    Puppet_X::Elastic.deep_implode arg
  end
end
