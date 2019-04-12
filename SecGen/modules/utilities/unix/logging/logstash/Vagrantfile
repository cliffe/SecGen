# This Vagrant file is provided as a convenience for development and
# exploratory testing of puppet-logstash. It's not used by the formal
# testing framwork, it's just for hacking.
#
# See `CONTRIBUTING.md` for details on formal testing.
puppet_code_root = '/etc/puppetlabs/code/environments/production'
module_root = "#{puppet_code_root}/modules/logstash"
manifest_dir = "#{puppet_code_root}/manifests"

Vagrant.configure(2) do |config|
  # config.vm.box = 'puppetlabs/debian-8.2-64-puppet'
  config.vm.box = 'bento/centos-7.3'
  config.vm.provider 'virtualbox' do |vm|
    vm.memory = 4 * 1024
  end

  # Make the Logstash module available.
  %w(manifests templates files).each do |dir|
    config.vm.synced_folder(dir, "#{module_root}/#{dir}")
  end

  # Map in a Puppet manifest that can be used for experiments.
  config.vm.synced_folder('Vagrantfile.d/manifests', "#{puppet_code_root}/manifests")

  # Prepare a puppetserver install so we can test the module in a realistic
  # way. 'puppet apply' is cool, but in reality, most people need this to work
  # in a master/agent configuration.
  config.vm.provision('shell', path: 'Vagrantfile.d/server.sh')
end
