require 'beaker-pe'
require 'beaker-puppet'
require 'puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'beaker/i18n_helper'
require 'beaker-task_helper'
require 'beaker/testmode_switcher'
require 'beaker/testmode_switcher/dsl'

run_puppet_install_helper
configure_type_defaults_on(hosts)
install_ca_certs unless pe_install?
install_bolt_on(hosts) unless pe_install?
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # detect the situation where PUP-5016 is triggered and skip the idempotency tests in that case
  # also note how fact('puppetversion') is not available because of PUP-4359
  if fact('osfamily') == 'Debian' && fact('operatingsystemmajrelease') == '8' && shell('puppet --version').stdout =~ %r{^4\.2}
    c.filter_run_excluding skip_pup_5016: true
  end

  # Configure all nodes in nodeset
  c.before :suite do
    run_puppet_access_login(user: 'admin') if pe_install? && (Gem::Version.new(puppet_version) >= Gem::Version.new('5.0.0'))
    hosts.each do |host|
      # This will be removed, this is temporary to test localisation.
      if (fact('osfamily') == 'Debian' || fact('osfamily') == 'RedHat') &&
         (Gem::Version.new(puppet_version) >= Gem::Version.new('4.10.5') &&
          Gem::Version.new(puppet_version) < Gem::Version.new('5.2.0'))
        on(host, 'mkdir /opt/puppetlabs/puppet/share/locale/ja')
        on(host, 'touch /opt/puppetlabs/puppet/share/locale/ja/puppet.po')
      end
      if fact('osfamily') == 'Debian'
        # install language on debian systems
        install_language_on(host, 'ja_JP.utf-8') if not_controller(host)
        # This will be removed, this is temporary to test localisation.
      end
      # Required for binding tests.
      if fact('osfamily') == 'RedHat'
        if fact('operatingsystemmajrelease') =~ %r{7} || fact('operatingsystem') =~ %r{Fedora}
          shell('yum install -y bzip2')
        end
      end
      on host, puppet('module', 'install', 'stahnma/epel')
    end
  end
end

shared_examples 'a idempotent resource' do
  it 'applies with no errors' do
    execute_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes', :skip_pup_5016 do
    execute_manifest(pp, catch_changes: true)
  end
end
