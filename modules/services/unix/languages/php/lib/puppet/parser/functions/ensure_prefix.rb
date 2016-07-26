
module Puppet::Parser::Functions
  newfunction(:ensure_prefix, :type => :rvalue, :doc => <<-EOS
This function ensures a prefix for all elements in an array or the keys in a hash.

*Examples:*

  ensure_prefix({'a' => 1, 'b' => 2, 'p.c' => 3}, 'p.')

Will return:
  {
    'p.a' => 1,
    'p.b' => 2,
    'p.c' => 3,
  }

  ensure_prefix(['a', 'p.b', 'c'], 'p.')

Will return:
  ['p.a', 'p.b', 'p.c']
EOS
  ) do |arguments|

    raise(Puppet::ParseError, "ensure_prefix(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size < 2

    enumerable = arguments[0]

    unless enumerable.is_a?(Array) or enumerable.is_a?(Hash)
      raise Puppet::ParseError, "ensure_prefix(): expected first argument to be an Array or a Hash, got #{enumerable.inspect}"
    end

    prefix = arguments[1] if arguments[1]

    if prefix
      unless prefix.is_a?(String)
        raise Puppet::ParseError, "ensure_prefix(): expected second argument to be a String, got #{prefix.inspect}"
      end
    end

    if enumerable.is_a?(Array)
      # Turn everything into string same as join would do ...
      result = enumerable.collect do |i|
        i = i.to_s
        prefix && !i.start_with?(prefix) ? prefix + i : i
      end
    else
      result = Hash[enumerable.map do |k,v|
        k = k.to_s
        [ prefix && !k.start_with?(prefix) ? prefix + k : k, v ]
      end]
    end

    return result
  end
end
