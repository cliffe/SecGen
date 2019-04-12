require 'shellwords'
#
# docker_swarm_join_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of docker swarm init flags
  newfunction(:docker_swarm_join_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['join'].to_s != 'false'
      flags << 'join'
    end

    if opts['advertise_addr'].to_s != 'undef'
      flags << "--advertise-addr '#{opts['advertise_addr']}'"
    end

    if opts['listen_addr'].to_s != 'undef'
      flags << "--listen-addr \"#{opts['listen_addr']}\""
    end

    if opts['token'].to_s != 'undef'
      flags << "--token '#{opts['token']}'"
    end

    flags.flatten.join(' ')
  end
end
