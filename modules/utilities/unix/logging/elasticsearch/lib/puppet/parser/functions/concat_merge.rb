# Top-level Puppet functions
module Puppet::Parser::Functions
  newfunction(
    :concat_merge,
    :type => :rvalue,
    :doc => <<-'ENDHEREDOC') do |args|
    Merges two or more hashes together concatenating duplicate keys
    with array values and returns the resulting hash.

    For example:

        $hash1 = {'a' => [1]}
        $hash2 = {'a' => [2]}
        concat_merge($hash1, $hash2)
        # The resulting hash is equivalent to:
        # { 'a' => [1, 2] }

    When there is a duplicate key that is not an array, the key in
    the rightmost hash will "win."

    @return String
    ENDHEREDOC

    if args.length < 2
      raise Puppet::ParseError, "concat_merge(): wrong number of arguments (#{args.length}; must be at least 2)"
    end

    concat_merge = proc do |hash1, hash2|
      hash1.merge(hash2) do |_key, old_value, new_value|
        if old_value.is_a?(Array) && new_value.is_a?(Array)
          old_value + new_value
        else
          new_value
        end
      end
    end

    result = {}
    args.each do |arg|
      next if arg.is_a? String and arg.empty? # empty string is synonym for puppet's undef
      # If the argument was not a hash, skip it.
      unless arg.is_a?(Hash)
        raise Puppet::ParseError, "concat_merge: unexpected argument type #{arg.class}, only expects hash arguments"
      end

      result = concat_merge.call(result, arg)
    end
    result
  end
end
