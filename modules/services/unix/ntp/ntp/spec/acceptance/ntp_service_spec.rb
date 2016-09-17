require 'spec_helper_acceptance'
require 'specinfra'

case fact('osfamily')
  when 'RedHat', 'FreeBSD', 'Linux', 'Gentoo'
    servicename = 'ntpd'
  when 'Solaris'
    servicename = 'network/ntp'
  when 'AIX'
    servicename = 'xntpd'
  else
    if fact('operatingsystem') == 'SLES' and fact('operatingsystemmajrelease') == '12'
      servicename = 'ntpd'
    else
      servicename = 'ntp'
    end
end
shared_examples 'running' do
  describe service(servicename) do
    if !(fact('operatingsystem') == 'SLES' && fact('operatingsystemmajrelease') == '12')
      it { should be_running }
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
    else
      # hack until we either update SpecInfra or come up with alternative
      it {
        output = shell('service ntpd status')
        expect(output.stdout).to match(/Active\:\s+active\s+\(running\)/)
        expect(output.stdout).to match(/^\s+Loaded.*enabled\)$/)
      }
    end
  end
end
describe 'ntp::service class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  describe 'basic test' do
    it 'sets up the service' do
      apply_manifest(%{
        class { 'ntp': }
      }, :catch_failures => true)
    end

    it_should_behave_like 'running'
  end

  describe 'service parameters' do
    it 'starts the service' do
      pp = <<-EOS
      class { 'ntp':
        service_enable => true,
        service_ensure => running,
        service_manage => true,
        service_name   => '#{servicename}'
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end
    it_should_behave_like 'running'
  end
end

describe 'service is unmanaged' do
  it 'shouldnt stop the service' do
    pp = <<-EOS
      class { 'ntp':
        service_enable => false,
        service_ensure => stopped,
        service_manage => false,
        service_name   => '#{servicename}'
      }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  describe service(servicename) do
    if !(fact('operatingsystem') == 'SLES' && fact('operatingsystemmajrelease') == '12')
      it { should be_running }
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
    else
      # hack until we either update SpecInfra or come up with alternative
      output = shell('service ntpd status', :acceptable_exit_codes => [0, 3])
      it 'should be disabled' do
        expect(output.stdout).to match(/^\s+Loaded.*disabled\)$/)
      end
      it 'should be stopped' do
        expect(output.stdout).to match(/Active\:\s+inactive/)
      end
    end
  end
end

