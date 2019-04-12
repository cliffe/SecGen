require 'spec_helper'

describe 'docker::system_user', :type => :define do
  let(:title) { 'testuser' }
	let(:facts) { {
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
                :os                        => { :distro => { :codename => 'wheezy' }, :family => 'Debian', :name => 'Debian', :release => { :major => '7', :full => '7.0' } }
	} }
  
  context 'with default' do
    let(:params) { {'create_user' => true} }
    it { should contain_user('testuser') }
    it { should contain_exec('docker-system-user-testuser').with_command(/docker testuser/) }
    it { should contain_exec('docker-system-user-testuser').with_unless(/grep -qw testuser/) }
  end

  context 'with create_user => false' do
    let(:params) { {'create_user' => false} }
    it { should contain_exec('docker-system-user-testuser').with_command(/docker testuser/) }
  end

end
