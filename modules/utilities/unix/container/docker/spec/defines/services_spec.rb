require 'spec_helper'

describe 'docker::services', :type => :define do
  let(:title) { 'test_service' }
	let(:facts) { {
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
	} }

  context 'with ensure => present and service create' do
    let(:params) { {
	    'create'       => true,
	    'service_name' => 'foo',
      'image'        => 'foo:bar',
	    'publish'      => '80:80',
      'replicas'     => '5',
      'extra_params' => ['--update-delay 1m', '--restart-window 30s'],
      'env'          => ['MY_ENV=1', 'MY_ENV2=2'],
      'label'        => ['com.example.foo="bar"', 'bar=baz'],
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('test_service docker service create').with_command(/docker service create/) }
    it { should contain_exec('test_service docker service create').with_command(/--env MY_ENV=1/) }
    it { should contain_exec('test_service docker service create').with_command(/--label bar=baz/) }

    context 'multiple services declaration' do
      let(:pre_condition) {
        "
        docker::services { 'test_service_2':
          service_name => 'foo_2',
          image        => 'foo:bar',
        }
        "
      }
      it { should contain_exec('test_service docker service create').with_command(/docker service create/) }
      it { should contain_exec('test_service_2 docker service create').with_command(/docker service create/) }
    end
  end

  context 'with ensure => present and service update' do
    let(:params) { {
	    'create'         => false,
	    'update'         => true,
      'service_name'   => 'foo',
	    'image'          => 'bar:latest',
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('test_service docker service update').with_command(/docker service update/) }
  end

  context 'with ensure => present and service scale' do
    let(:params) { {
	    'create'         => false,
	    'scale'          => true,
      'service_name'   => 'bar',
	    'replicas'       => '5',
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('test_service docker service scale').with_command(/docker service scale/) }
  end

  context 'with ensure => absent' do
    let(:params) { {
	    'ensure'         => 'absent',
	    'service_name'   => 'foo',
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('test_service docker service remove').with_command(/docker service rm/) }
  end

  context 'when adding a system user' do
    let(:params) { {
        'user' => ['user1'],
    } }
    it { is_expected.to compile.with_all_deps }
    it { should_not contain_exec('docker-systemd-reload-before-service') }
  end
end
