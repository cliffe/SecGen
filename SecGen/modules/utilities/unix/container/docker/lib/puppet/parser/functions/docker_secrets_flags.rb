require 'shellwords'
#
# docker_secrets_flags.rb
#
module Puppet::Parser::Functions
  # Transforms a hash into a string of docker swarm init flags
  newfunction(:docker_secrets_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['ensure'].to_s == 'present'
      flags << 'create'
    end

    if opts['secret_name'].to_s != 'undef'
      flags << "'#{opts['secret_name']}'"
    end

    if opts['secret_path'].to_s != 'undef'
      flags << "'#{opts['secret_path']}'"
    end

    multi_flags = lambda { |values, format|
      filtered = [values].flatten.compact
      filtered.map { |val| sprintf(format + " \\\n", val) }
    }
    [
      ['-l %s', 'label'],
    ].each do |(format, key)|
      values    = opts[key]
      new_flags = multi_flags.call(values, format)
      flags.concat(new_flags)
    end

    flags.flatten.join(' ')
  end
end
