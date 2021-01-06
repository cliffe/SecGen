#
# basename.rb
#
module Puppet::Parser::Functions
  newfunction(:basename, :type => :rvalue, :doc => <<-DOC
    Strips directory (and optional suffix) from a filename
    DOC
             ) do |arguments|

    raise(Puppet::ParseError, 'basename(): No arguments given') if arguments.empty?
    raise(Puppet::ParseError, "basename(): Too many arguments given (#{arguments.size})") if arguments.size > 2
    raise(Puppet::ParseError, 'basename(): Requires string as first argument') unless arguments[0].is_a?(String)

    rv = File.basename(arguments[0]) if arguments.size == 1
    if arguments.size == 2
      raise(Puppet::ParseError, 'basename(): Requires string as second argument') unless arguments[1].is_a?(String)
      rv = File.basename(arguments[0], arguments[1])
    end

    return rv
  end
end

# vim: set ts=2 sw=2 et :
