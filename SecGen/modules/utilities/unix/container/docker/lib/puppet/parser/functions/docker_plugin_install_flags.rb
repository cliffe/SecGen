require 'shellwords'
#
# docker_plugin_install_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of docker plugin install flags
  newfunction(:docker_plugin_install_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    flags << "--alias #{opts['plugin_alias']}" if opts['plugin_alias'].to_s != 'undef'
    flags << '--disable' if opts['disable_on_install'] == true
    flags << '--disable-content-trust' if opts['disable_content_trust'] == true
    flags << '--grant-all-permissions' if opts['grant_all_permissions'] == true
    flags << "'#{opts['plugin_name']}'" if opts['plugin_name'].to_s != 'undef'
    if opts['settings'].is_a? Array
      opts['settings'].each do |setting|
        flags << setting.to_s
      end
    end
    flags.flatten.join(' ')
  end
end
