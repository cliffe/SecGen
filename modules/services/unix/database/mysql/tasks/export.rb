#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def get(file, database, user, password)
  cmd_string = 'mysqldump'
  cmd_string << " --databases #{database}" unless database.nil?
  cmd_string << " --user=#{user}" unless user.nil?
  cmd_string << " --password=#{password}" unless password.nil?
  cmd_string << " > #{file}" unless file.nil?
  stdout, _stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, _("stderr: ' %{stderr}') % { stderr: stderr }") if status != 0
  { status: stdout.strip }
end

params = JSON.parse(STDIN.read)
database = params['database']
user = params['user']
password = params['password']
file = params['file']

begin
  result = get(file, database, user, password)
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
