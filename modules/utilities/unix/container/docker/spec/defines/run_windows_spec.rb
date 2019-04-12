require 'spec_helper'

describe 'docker::run', :type => :define do
  let(:title) { 'sample' }
  let(:facts) { {
    :architecture              => 'amd64',
    :osfamily                  => 'windows',
    :operatingsystem           => 'windows',
    :kernelrelease             => '10.0.14393',
    :operatingsystemrelease    => '2016',
    :operatingsystemmajrelease => '2016',
    :os                        => { :family => 'windows', :name => 'windows', :release => { :major => '2016', :full => '2016' } }
    } }
  command = 'docker'

  context 'with restart policy set to no' do
    let(:params) { {'restart' => 'no', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
    it { should contain_exec('run sample with docker') }
    it { should contain_exec('run sample with docker').with_unless(/sample/) }
    it { should contain_exec('run sample with docker').with_unless(/inspect/) }
    it { should contain_exec('run sample with docker').with_command(/--cidfile=c:\/Windows\/Temp\/docker-sample.cid/) }
    it { should contain_exec('run sample with docker').with_command(/-c 4/) }
    it { should contain_exec('run sample with docker').with_command(/--restart="no"/) }
    it { should contain_exec('run sample with docker').with_command(/base command/) }
    it { should contain_exec('run sample with docker').with_timeout(3000) }
  end

  context 'with restart policy set to always' do
    let(:params) { {'restart' => 'always', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
    it { should contain_exec('run sample with docker') }
    it { should contain_exec('run sample with docker').with_unless(/sample/) }
    it { should contain_exec('run sample with docker').with_unless(/inspect/) }
    it { should contain_exec('run sample with docker').with_command(/--cidfile=c:\/Windows\/Temp\/docker-sample.cid/) }
    it { should contain_exec('run sample with docker').with_command(/-c 4/) }
    it { should contain_exec('run sample with docker').with_command(/--restart="always"/) }
    it { should contain_exec('run sample with docker').with_command(/base command/) }
    it { should contain_exec('run sample with docker').with_timeout(3000) }
  end

  context 'with restart policy set to on-failure' do
    let(:params) { {'restart' => 'on-failure', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
    it { should contain_exec('run sample with docker') }
    it { should contain_exec('run sample with docker').with_unless(/sample/) }
    it { should contain_exec('run sample with docker').with_unless(/inspect/) }
    it { should contain_exec('run sample with docker').with_command(/--cidfile=c:\/Windows\/Temp\/docker-sample.cid/) }
    it { should contain_exec('run sample with docker').with_command(/-c 4/) }
    it { should contain_exec('run sample with docker').with_command(/--restart="on-failure"/) }
    it { should contain_exec('run sample with docker').with_command(/base command/) }
    it { should contain_exec('run sample with docker').with_timeout(3000) }
  end

  context 'with restart policy set to on-failure:3' do
    let(:params) { {'restart' => 'on-failure:3', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
    it { should contain_exec('run sample with docker') }
    it { should contain_exec('run sample with docker').with_unless(/sample/) }
    it { should contain_exec('run sample with docker').with_unless(/inspect/) }
    it { should contain_exec('run sample with docker').with_command(/--cidfile=c:\/Windows\/Temp\/docker-sample.cid/) }
    it { should contain_exec('run sample with docker').with_command(/-c 4/) }
    it { should contain_exec('run sample with docker').with_command(/--restart="on-failure:3"/) }
    it { should contain_exec('run sample with docker').with_command(/base command/) }
    it { should contain_exec('run sample with docker').with_timeout(3000) }
  end

  context 'with ensure absent' do
    let(:params) { {'ensure' => 'absent', 'command' => 'command', 'image' => 'base'} }
    it { should compile.with_all_deps }
    it { should contain_exec("stop container docker-sample").with_command('docker stop --time=0 sample') }
    it { should contain_exec("remove container docker-sample").with_command('docker rm -v sample') }
    it { should_not contain_file('c:/Windows/Temp/docker-sample.cid"')}
  end

  context 'with ensure absent and restart policy' do
    let(:params) { {'ensure' => 'absent', 'command' => 'command', 'image' => 'base', 'restart' => 'always'} }
    it { should compile.with_all_deps }
    it { should contain_exec("stop sample with docker").with_command('docker stop --time=0 sample') }
    it { should contain_exec("remove sample with docker").with_command('docker rm -v sample') }
    it { should_not contain_file('c:/Windows/Temp/docker-sample.cid"')}
  end

  context 'with ensure present and no restart policy' do
    let(:params) { {'ensure' => 'present', 'image' => 'base'} }
    it do
      expect {
        should_not contain_file('c:/Windows/Temp/docker-sample.cid"')
      }.to raise_error(Puppet::Error)
    end
  end
end
