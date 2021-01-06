#
# clamp.rb
#
module Puppet::Parser::Functions
  newfunction(:clamp, :type => :rvalue, :arity => -2, :doc => <<-DOC
    Clamps value to a range.
    DOC
             ) do |args|

    args.flatten!

    raise(Puppet::ParseError, 'clamp(): Wrong number of arguments, need three to clamp') if args.size != 3

    # check values out
    args.each do |value|
      case [value.class]
      when [String]
        raise(Puppet::ParseError, "clamp(): Required explicit numeric (#{value}:String)") unless value =~ %r{^\d+$}
      when [Hash]
        raise(Puppet::ParseError, "clamp(): The Hash type is not allowed (#{value})")
      end
    end

    # convert to numeric each element
    # then sort them and get a middle value
    args.map { |n| n.to_i }.sort[1]
  end
end
