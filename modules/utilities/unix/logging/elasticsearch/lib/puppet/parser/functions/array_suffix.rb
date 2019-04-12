# Top-level Puppet functions
module Puppet::Parser::Functions
  newfunction(
    :array_suffix,
    :type => :rvalue,
    :doc => <<-EOS
This function applies a suffix to all elements in an array.

*Examples:*

    array_suffix(['a','b','c'], 'p')

Will return: ['ap','bp','cp']

@return Array
    EOS
  ) do |arguments|
    # Technically we support two arguments but only first is mandatory ...
    raise(Puppet::ParseError, 'array_suffix(): Wrong number of arguments ' \
      "given (#{arguments.size} for 1)") if arguments.empty?

    array = arguments[0]

    unless array.is_a?(Array)
      raise Puppet::ParseError, "array_suffix(): expected first argument to be an Array, got #{array.inspect}"
    end

    suffix = arguments[1] if arguments[1]

    if suffix
      unless suffix.is_a? String
        raise Puppet::ParseError, "array_suffix(): expected second argument to be a String, got #{suffix.inspect}"
      end
    end

    # Turn everything into string same as join would do ...
    result = array.collect do |i|
      i = i.to_s
      suffix ? i + suffix : i
    end

    return result
  end
end

# vim: set ts=2 sw=2 et :
