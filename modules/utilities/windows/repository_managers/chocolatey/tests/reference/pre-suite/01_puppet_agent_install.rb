test_name 'Install Puppet Agent'

confine(:to, :platform => 'windows')

step 'Install Puppet Agent'
if ENV['BEAKER_PUPPET_AGENT_VERSION']
  install_puppet_agent_on(agents, :version => ENV['BEAKER_PUPPET_AGENT_VERSION'])
else
  install_puppet_agent_on(agents)
end

step 'Prevent Puppet Service from Running'
on(agents, puppet('resource service puppet ensure=stopped enable=false'))
