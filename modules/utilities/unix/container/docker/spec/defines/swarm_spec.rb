require 'spec_helper'

['Debian', 'Windows'].each do |osfamily|
  describe 'docker::swarm', :type => :define do
    let(:title) { 'create swarm' }
    context "on #{osfamily}" do
      if osfamily == 'Debian'
        let(:facts) { {
          :osfamily                  => 'Debian',
          :operatingsystem           => 'Debian',
          :lsbdistid                 => 'Debian',
          :lsbdistcodename           => 'jessie',
          :kernelrelease             => '3.2.0-4-amd64',
          :operatingsystemmajrelease => '8',
        } }
      elsif osfamily == 'Windows'
        let(:facts) { {
          :osfamily                  => 'Windows',
          :operatingsystem           => 'Windows',
          :kernelrelease             => '10.0.14393',
          :operatingsystemmajrelease => '2016',
        } }
      end

      context 'with ensure => present and swarm init' do
        let(:params) { {
          'init'           => true,
          'advertise_addr' => '192.168.1.1',
                'listen_addr'    => '192.168.1.1',    
        } }
        it { is_expected.to compile.with_all_deps }
        it { should contain_exec('Swarm init').with_command(/docker swarm init/) }
      end

      context 'with ensure => present and swarm join' do
        let(:params) { {
          'join'           => true,
          'advertise_addr' => '192.168.1.1',
                'listen_addr'    => '192.168.1.1',
          'token'          => 'foo',
          'manager_ip'     => '192.168.1.2'
        } }
        it { is_expected.to compile.with_all_deps }
        it { should contain_exec('Swarm join').with_command(/docker swarm join/) }
      end

      context 'with ensure => absent' do
        let(:params) { {
          'ensure'         => 'absent',
          'join'           => true,
          'advertise_addr' => '192.168.1.1',
                'listen_addr'    => '192.168.1.1',
          'token'          => 'foo',
          'manager_ip'     => '192.168.1.2'
        } }
        it { is_expected.to compile.with_all_deps }
        it { should contain_exec('Leave swarm').with_command(/docker swarm leave --force/) }
      end
    end
  end
end
