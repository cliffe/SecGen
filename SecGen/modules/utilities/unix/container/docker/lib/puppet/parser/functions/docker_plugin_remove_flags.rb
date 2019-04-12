require 'shellwords'
#
# docker_plugin_remove_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of docker plugin remove flags
  newfunction(:docker_plugin_remove_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    flags << '--force' if opts['force_remove'] == true
    flags << "'#{opts['plugin_name']}'" if opts['plugin_name'].to_s != 'undef'
    flags.flatten.join(' ')
  end
end
