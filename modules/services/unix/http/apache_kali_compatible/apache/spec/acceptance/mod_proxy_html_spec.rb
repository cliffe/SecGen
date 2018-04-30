require 'spec_helper_acceptance'
require_relative './version.rb'

# Don't run proxy_html tests on RHEL7 because the yum repos are missing packages required by it.
describe 'apache::mod::proxy_html class', :unless => (fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '7') do
  context "default proxy_html config" do
    if fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') =~ /(5|6)/
      it 'adds epel' do
        pp = "class { 'epel': }"
        apply_manifest(pp, :catch_failures => true)
      end
    end

    it 'succeeds in puppeting proxy_html' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::proxy': }
        class { 'apache::mod::proxy_http': }
        # mod_proxy_html doesn't exist in RHEL5
        if $::osfamily == 'RedHat' and $::operatingsystemmajrelease != '5' {
          class { 'apache::mod::proxy_html': }
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end
  end
end
