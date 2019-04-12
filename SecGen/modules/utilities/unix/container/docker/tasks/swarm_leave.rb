#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def swarm_leave(force)
  cmd_string = "docker swarm leave "
  cmd_string << " -f" if force == "true"
  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, ("stderr: '#{stderr}'") if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
force = params['force']
begin
  result = swarm_leave(force)
  puts result
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message })
  exit 1
end