#
# type3x.rb
#
module Puppet::Parser::Functions
  newfunction(:type3x, :type => :rvalue, :doc => <<-DOC
    DEPRECATED: This function will be removed when puppet 3 support is dropped; please migrate to the new parser's typing system.

    Returns the type when passed a value. Type can be one of:

    * string
    * array
    * hash
    * float
    * integer
    * boolean
  DOC
             ) do |args|
    raise(Puppet::ParseError, "type3x(): Wrong number of arguments given (#{args.size} for 1)") unless args.size == 1

    value = args[0]

    klass = value.class

    unless [TrueClass, FalseClass, Array, Bignum, Fixnum, Float, Hash, String].include?(klass) # rubocop:disable Lint/UnifiedInteger
      raise(Puppet::ParseError, 'type3x(): Unknown type')
    end

    klass = klass.to_s # Ugly ...

    # We note that Integer is the parent to Bignum and Fixnum ...
    result = case klass
             when %r{^(?:Big|Fix)num$} then 'integer'
             when %r{^(?:True|False)Class$} then 'boolean'
             else klass
             end

    if result == 'String'
      if value == value.to_i.to_s
        result = 'Integer'
      elsif value == value.to_f.to_s
        result = 'Float'
      end
    end

    return result.downcase
  end
end

# vim: set ts=2 sw=2 et :
