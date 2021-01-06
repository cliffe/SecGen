#
# parsejson.rb
#
module Puppet::Parser::Functions
  newfunction(:parsejson, :type => :rvalue, :doc => <<-DOC
    This function accepts JSON as a string and converts it into the correct
    Puppet structure.

    The optional second argument can be used to pass a default value that will
    be returned if the parsing of YAML string have failed.
  DOC
             ) do |arguments|
    raise ArgumentError, 'Wrong number of arguments. 1 or 2 arguments should be provided.' unless arguments.length >= 1

    begin
      PSON.load(arguments[0]) || arguments[1]
    rescue StandardError => e
      raise e unless arguments[1]
      arguments[1]
    end
  end
end

# vim: set ts=2 sw=2 et :
