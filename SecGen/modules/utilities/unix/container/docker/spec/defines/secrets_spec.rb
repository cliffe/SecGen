require 'spec_helper'

describe 'docker::secrets', :type => :define do
  let(:title) { 'test_secret' }
  let(:facts) { {
    :osfamily                  => 'Debian',
    :operatingsystem           => 'Debian',
    :lsbdistid                 => 'Debian',
    :lsbdistcodename           => 'jessie',
    :kernelrelease             => '3.2.0-4-amd64',
    :operatingsystemmajrelease => '8',
  } }

  context 'with secret_name => test_secret and secret_path => /root/secret.txt and label => test' do
    let(:params) { {
      'secret_name' => 'test_secret',
      'secret_path' => '/root/secret.txt',
      'label' => ['test'],
    } }
    it { should contain_exec('test_secret docker secret create').with_command(/docker secret create/) }
    context 'multiple secrets declaration' do
      let(:pre_condition) {
        "
        docker::secrets{'test_secret_2':
          secret_name => 'test_secret_2',
          secret_path => '/root/secret_2.txt',
        }
        "
      }
      it { should contain_exec('test_secret docker secret create').with_command(/docker secret create/) }
      it { should contain_exec('test_secret_2 docker secret create').with_command(/docker secret create/) }
    end
  end

  context 'with ensure => absent and secret_name => test_secret' do
    let(:params) { {
      'ensure' => 'absent',
      'secret_name' => 'test_secret'} }
    it { should contain_exec('test_secret docker secret rm').with_command(/docker secret rm/) }
  end


end
