require 'digest/sha1'
module Puppet::Parser::Functions
  newfunction(:mysql_password, type: :rvalue, doc: <<-EOS
    @summary
      Hash a string as mysql's "PASSWORD()" function would do it

    @param [String] password Plain text password.

    @return [String] the mysql password hash from the clear text password.
    EOS
             ) do |args|

    if args.size != 1
      raise Puppet::ParseError, _('mysql_password(): Wrong number of arguments given (%{args_length} for 1)') % { args_length: args.length }
    end

    return '' if args[0].empty?
    return args[0] if args[0] =~ %r{\*[A-F0-9]{40}$}
    '*' + Digest::SHA1.hexdigest(Digest::SHA1.digest(args[0])).upcase
  end
end
