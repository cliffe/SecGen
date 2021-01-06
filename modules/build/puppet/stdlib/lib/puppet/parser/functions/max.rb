#
# max.rb
#
module Puppet::Parser::Functions
  newfunction(:max, :type => :rvalue, :doc => <<-DOC
    Returns the highest value of all arguments.
    Requires at least one argument.
    DOC
             ) do |args|

    raise(Puppet::ParseError, 'max(): Wrong number of arguments need at least one') if args.empty?

    # Sometimes we get numbers as numerics and sometimes as strings.
    # We try to compare them as numbers when possible
    return args.max do |a, b|
      if a.to_s =~ %r{\A-?\d+(.\d+)?\z} && b.to_s =~ %r{\A-?\d+(.\d+)?\z}
        a.to_f <=> b.to_f
      else
        a.to_s <=> b.to_s
      end
    end
  end
end
