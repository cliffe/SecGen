# Custom Puppet function to convert dos to unix format
module Puppet::Parser::Functions
  newfunction(:dos2unix, :type => :rvalue, :arity => 1, :doc => <<-EOS
    Returns the Unix version of the given string.
    Takes a single string argument.
    EOS
  ) do |arguments|

    unless arguments[0].is_a?(String)
      raise(Puppet::ParseError, 'dos2unix(): Requires string as argument')
    end

    arguments[0].gsub(/\r\n/, "\n")
  end
end
