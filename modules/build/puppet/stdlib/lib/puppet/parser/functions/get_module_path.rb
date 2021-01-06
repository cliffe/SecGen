#
# get_module_path.rb
#
module Puppet::Parser::Functions
  newfunction(:get_module_path, :type => :rvalue, :doc => <<-DOC
    Returns the absolute path of the specified module for the current
    environment.

    Example:
      $module_path = get_module_path('stdlib')
  DOC
             ) do |args|
    raise(Puppet::ParseError, 'get_module_path(): Wrong number of arguments, expects one') unless args.size == 1
    module_path = Puppet::Module.find(args[0], compiler.environment.to_s)
    raise(Puppet::ParseError, "Could not find module #{args[0]} in environment #{compiler.environment}") unless module_path
    module_path.path
  end
end
