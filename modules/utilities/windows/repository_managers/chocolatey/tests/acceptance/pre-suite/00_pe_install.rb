require 'master_manipulator'
test_name 'MODULES-3138 - C48 - Install Puppet Enterprise'

# Check for a master before continuing
if master == nil
  fail_test("Master is not set, are you using a host configuration that has a master?")
end

# Init
step 'Install PE'
install_pe

step 'Disable Node Classifier'
disable_node_classifier(master)

step 'Disable Environment Caching'
disable_env_cache(master)

step 'Restart Puppet Server'
restart_puppet_server(master)
