require 'spec_helper'

describe 'docker::registry', :type => :define do
  let(:title) { 'localhost:5000' }
	let(:facts) { {
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
	} }
  let(:params) { { 'version' => '17.06', 'pass_hash' => 'test1234', 'receipt' => false } }
  it { should contain_exec('localhost:5000 auth') }

  context 'with ensure => present' do
    let(:params) { { 'ensure' => 'absent', 'version' => '17.06', 'pass_hash' => 'test1234', 'receipt' => false } }
    it { should contain_exec('localhost:5000 auth').with_command('docker logout localhost:5000') }
  end

  context 'with ensure => present' do
    let(:params) { { 'ensure' => 'present', 'version' => '17.06', 'pass_hash' => 'test1234', 'receipt' => false } }
    it { should contain_exec('localhost:5000 auth').with_command('docker login localhost:5000') }
  end

  context 'with ensure => present and username => user1' do
    let(:params) { { 'ensure' => 'present', 'username' => 'user1', 'version' => '17.06', 'pass_hash' => 'test1234', 'receipt' => false } }
    it { should contain_exec('localhost:5000 auth').with_command('docker login localhost:5000') }
  end

  context 'with ensure => present and password => secret' do
    let(:params) { { 'ensure' => 'present', 'password' => 'secret', 'version' => '17.06', 'pass_hash' => 'test1234', 'receipt' => false } }
    it { should contain_exec('localhost:5000 auth').with_command('docker login localhost:5000') }
  end

  context 'with ensure => present and email => user1@example.io' do
    let(:params) { { 'ensure' => 'present', 'email' => 'user1@example.io', 'version' => '17.06', 'pass_hash' => 'test1234', 'receipt' => false } }
    it { should contain_exec('localhost:5000 auth').with_command('docker login localhost:5000') }
  end

  context 'with ensure => present and username => user1, and password => secret and email => user1@example.io' do
    let(:params) { { 'ensure' => 'present', 'username' => 'user1', 'password' => 'secret', 'email' => 'user1@example.io', 'version' => '17.06', 'pass_hash' => 'test1234', 'receipt' => false } }
    it { should contain_exec('localhost:5000 auth').with_command("docker login -u 'user1' -p \"${password}\" localhost:5000").with_environment(/password=secret/) }
  end

 context 'with ensure => present and username => user1, and password => secret and email => user1@example.io and version < 1.11.0' do
    let(:params) { { 'ensure' => 'present', 'username' => 'user1', 'password' => 'secret', 'email' => 'user1@example.io', 'version' => '1.9.0', 'pass_hash' => 'test1234', 'receipt' => false } }
    it { should contain_exec('localhost:5000 auth').with_command("docker login -u 'user1' -p \"${password}\" -e 'user1@example.io' localhost:5000").with_environment(/password=secret/) }
  end

  context 'with username => user1, and password => secret' do
    let(:params) { { 'username' => 'user1', 'password' => 'secret', 'version' => '17.06', 'pass_hash' => 'test1234', 'receipt' => false } }
    it { should contain_exec('localhost:5000 auth').with_command("docker login -u 'user1' -p \"${password}\" localhost:5000").with_environment(/password=secret/) }
  end

  context 'with username => user1, and password => secret and local_user => testuser' do
    let(:params) { { 'username' => 'user1', 'password' => 'secret', 'local_user' => 'testuser', 'version' => '17.06', 'pass_hash' => 'test1234', 'receipt' => false } }
    it { should contain_exec('localhost:5000 auth').with_command("docker login -u 'user1' -p \"${password}\" localhost:5000").with_user('testuser').with_environment(/password=secret/) }
  end

  context 'with an invalid ensure value' do
    let(:params) { { 'ensure' => 'not present or absent' } }
    it do
      expect {
        should contain_exec('docker logout localhost:5000')
      }.to raise_error(Puppet::Error)
    end
  end
end
