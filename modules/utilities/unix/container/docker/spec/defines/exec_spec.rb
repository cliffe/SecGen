require 'spec_helper'

describe 'docker::exec', :type => :define do
  let(:title) { 'sample' }
	let(:facts) { {
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
	} }

  context 'when running detached' do
		let(:params) { {'command' => 'command', 'container' => 'container', 'detach' => true} }
		it { should contain_exec('docker exec --detach=true container command') }
  end

  context 'when running with tty' do
		let(:params) { {'command' => 'command', 'container' => 'container', 'tty' => true} }
		it { should contain_exec('docker exec --tty=true container command') }
  end

  context 'when running with interactive' do
		let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true} }
		it { should contain_exec('docker exec --interactive=true container command') }
  end

  context 'when running with onlyif "running"' do
		let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true, 'onlyif' => 'running'} }
		it { should contain_exec('docker exec --interactive=true container command').with_onlyif ('docker ps --no-trunc --format=\'table {{.Names}}\' | grep \'^container$\'') }
  end

  context 'when running without onlyif custom command' do
		let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true, 'onlyif' => 'custom'} }
		it { should contain_exec('docker exec --interactive=true container command').with_onlyif ('custom') }
  end

  context 'when running without onlyif' do
		let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true} }
		it { should contain_exec('docker exec --interactive=true container command').with_onlyif (nil) }
  end

  context 'when running with unless' do
		let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true, 'unless' => 'some_command arg1'} }
		it { should contain_exec('docker exec --interactive=true container command').with_unless ('docker exec --interactive=true container some_command arg1') }
  end

  context 'when running without unless' do
		let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true,} }
		it { should contain_exec('docker exec --interactive=true container command').with_unless (nil) }
  end

  context 'with title that need sanitisation' do
		let(:params) { {'command' => 'command', 'container' => 'container_sample/1', 'detach' => true, 'sanitise_name' => true} }
		it { should contain_exec('docker exec --detach=true container_sample-1 command') }
  end

  context 'with environment variables passed to exec' do
		let(:params) { {'command' => 'command', 'container' => 'container', 'env' => ['FOO=BAR','FOO2=BAR2']} }
		it { should contain_exec('docker exec --env FOO=BAR --env FOO2=BAR2 container command') }
  end
end
