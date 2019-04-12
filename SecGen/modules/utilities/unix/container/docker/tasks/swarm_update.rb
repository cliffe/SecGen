#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def swarm_update(image, service)
  cmd_string = "docker service update"
  cmd_string << " --image #{image}" unless image.nil?
  cmd_string << " #{service}" unless service.nil?

  stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, ("stderr: '#{stderr}'") if status != 0
  stdout.strip
end

params = JSON.parse(STDIN.read)
image = params['image']
service = params['service']

begin
  result = swarm_update(image, service)
  puts result
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message })
  exit 1
end
