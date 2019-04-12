#
# is_ipv6_address.rb
#

module Puppet::Parser::Functions
  newfunction(:is_ipv6_address, :type => :rvalue, :doc => <<-EOS
Returns true if the string passed to this function is a valid IPv6 address.
    EOS
  ) do |arguments|

    function_deprecation([:is_ipv6_address, 'This method is deprecated, please use the stdlib validate_legacy function, with Stdlib::Compat::Ipv6. There is further documentation for validate_legacy function in the README.'])

    require 'ipaddr'

    if (arguments.size != 1) then
      raise(Puppet::ParseError, "is_ipv6_address(): Wrong number of arguments given #{arguments.size} for 1")
    end

    begin
      ip = IPAddr.new(arguments[0])
    rescue ArgumentError
      return false
    end

    return ip.ipv6?
  end
end

# vim: set ts=2 sw=2 et :
