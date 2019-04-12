#
#  glob.rb
#

module Puppet::Parser::Functions
  newfunction(:glob, :type => :rvalue, :doc => <<-'EOS'
    Returns an Array of file entries of a directory or an Array of directories.
    Uses same patterns as Dir#glob
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "glob(): Wrong number of arguments given " +
      "(#{arguments.size} for 1)") unless arguments.size == 1

    pattern = arguments[0]

    raise(Puppet::ParseError, 'glob(): Requires either array or string ' +
      'to work') unless pattern.is_a?(String) || pattern.is_a?(Array)

    Dir.glob(pattern)
  end
end
