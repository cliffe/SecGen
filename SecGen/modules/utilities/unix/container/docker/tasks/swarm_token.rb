#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def swarm_token(node_role)
  cmd_string = "docker swarm join-token -q"
  cmd_string << " #{node_role}" unless node_role.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, ("stderr: '#{stderr}'") if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
node_role = params['node_role']

begin
  result = swarm_token(node_role)
  puts result
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message })
  exit 1
end