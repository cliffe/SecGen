# Custom Puppet function to convert unix to dos format
module Puppet::Parser::Functions
  newfunction(:unix2dos, :type => :rvalue, :arity => 1, :doc => <<-DOC
    Returns the DOS version of the given string.
    Takes a single string argument.
    DOC
             ) do |arguments|

    unless arguments[0].is_a?(String)
      raise(Puppet::ParseError, 'unix2dos(): Requires string as argument')
    end

    arguments[0].gsub(%r{\r*\n}, "\r\n")
  end
end
