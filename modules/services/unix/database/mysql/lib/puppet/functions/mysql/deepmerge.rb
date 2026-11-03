# @summary Recursively merges two or more hashes together and returns the resulting hash.
#
# @example
#   $hash1 = {'one' => 1, 'two' => 2, 'three' => { 'four' => 4 } }
#   $hash2 = {'two' => 'dos', 'three' => { 'five' => 5 } }
#   $merged_hash = mysql_deepmerge($hash1, $hash2)
#   # The resulting hash is equivalent to:
#   # $merged_hash = { 'one' => 1, 'two' => 'dos', 'three' => { 'four' => 4, 'five' => 5 } }
#
# - When there is a duplicate key that is a hash, they are recursively merged.
# - When there is a duplicate key that is not a hash, the key in the rightmost hash will "win."
# - When there are conficting uses of dashes and underscores in two keys (which mysql would otherwise equate), the rightmost style will win.
#
Puppet::Functions.create_function(:'mysql::deepmerge') do
  def deepmerge(*args)
    if args.length < 2
      raise Puppet::ParseError, _('mysql_deepmerge(): wrong number of arguments (%{args_length}; must be at least 2)') % { args_length: args.length }
    end

    result = {}
    args.each do |arg|
      next if arg.is_a?(String) && arg.empty? # empty string is synonym for puppet's undef
      # If the argument was not a hash, skip it.
      unless arg.is_a?(Hash)
        raise Puppet::ParseError, _('mysql_deepmerge: unexpected argument type %{arg_class}, only expects hash arguments.') % { args_class: args.class }
      end

      # We need to make a copy of the hash since it is frozen by puppet
      current = deep_copy(arg)

      # Now we have to traverse our hash assigning our non-hash values
      # to the matching keys in our result while following our hash values
      # and repeating the process.
      overlay(result, current)
    end
    result
  end

  def normalized?(hash, key)
    return true if hash.key?(key)
    return false unless key =~ %r{-|_}
    other_key = key.include?('-') ? key.tr('-', '_') : key.tr('_', '-')
    return false unless hash.key?(other_key)
    hash[key] = hash.delete(other_key)
    true
  end

  def overlay(hash1, hash2)
    hash2.each do |key, value|
      if normalized?(hash1, key) && value.is_a?(Hash) && hash1[key].is_a?(Hash)
        overlay(hash1[key], value)
      else
        hash1[key] = value
      end
    end
  end

  def deep_copy(inputhash)
    return inputhash unless inputhash.is_a? Hash
    hash = {}
    inputhash.each do |k, v|
      hash.store(k, deep_copy(v))
    end
    hash
  end
end
