#
# is_email_address.rb
#
module Puppet::Parser::Functions
  newfunction(:is_email_address, :type => :rvalue, :doc => <<-DOC
    Returns true if the string passed to this function is a valid email address.
    DOC
             ) do |arguments|
    if arguments.size != 1
      raise(Puppet::ParseError, "is_email_address(): Wrong number of arguments given #{arguments.size} for 1")
    end

    # Taken from http://emailregex.com/ (simpler regex)
    valid_email_regex = %r{\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z}
    return (arguments[0] =~ valid_email_regex) == 0 # rubocop:disable Style/NumericPredicate : Changing to '.zero?' breaks the code
  end
end

# vim: set ts=2 sw=2 et :
