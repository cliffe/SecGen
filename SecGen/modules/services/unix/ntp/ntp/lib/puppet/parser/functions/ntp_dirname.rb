module Puppet::Parser::Functions
  newfunction(:ntp_dirname, :type => :rvalue, :doc => <<-EOS
    Returns the dirname of a path.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "ntp_dirname(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    warning("ntp_dirname(): this function is deprecated and will be removed at a later time.")

    path = arguments[0]
    return File.dirname(path)
  end
end

# vim: set ts=2 sw=2 et :
