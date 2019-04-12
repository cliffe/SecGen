require 'spec_helper'

describe 'docker::image', :type => :define do
  let(:title) { 'base' }
	let(:facts) { {
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
	} }

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }
    it { should contain_exec('docker rmi base') }
  end

  context 'with ensure => absent and force => true' do
    let(:params) { { 'ensure' => 'absent', 'force' => true } }
    it { should contain_exec('docker rmi -f base') }
  end

  context 'with ensure => absent and image_tag => precise' do
    let(:params) { { 'ensure' => 'absent', 'image_tag' => 'precise' } }
    it { should contain_exec('docker rmi base:precise') }
  end

  context 'with ensure => present' do
    let(:params) { { 'ensure' => 'present' } }
    it { should contain_file('/usr/local/bin/update_docker_image.sh') }
    it { should contain_exec('/usr/local/bin/update_docker_image.sh base') }
  end

  context 'with docker_file => Dockerfile' do
    let(:params) { { 'docker_file' => 'Dockerfile' }}
    it { should contain_exec('docker build -t base - < Dockerfile') }
  end

  context 'with ensure => present and docker_file => Dockerfile' do
    let(:params) { { 'ensure' => 'present', 'docker_file' => 'Dockerfile' } }
    it { should contain_exec('docker build -t base - < Dockerfile') }
  end

  context 'with docker_dir => /tmp/docker_images/test1 and docker_file => /tmp/docker_images/test1/Dockerfile_altbuild' do
    let(:params) { { 'docker_dir' => '/tmp/docker_images/test1', 'docker_file' => '/tmp/docker_images/test1/Dockerfile_altbuild' }}
    it { should contain_exec('docker build -t base -f /tmp/docker_images/test1/Dockerfile_altbuild /tmp/docker_images/test1') }
  end

  context 'with docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'docker_dir' => '/tmp/docker_images/test1' }}
    it { should contain_exec('docker build -t base /tmp/docker_images/test1') }
  end

  context 'with ensure => present and docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'ensure' => 'present', 'docker_dir' => '/tmp/docker_images/test1' } }
    it { should contain_exec('docker build -t base /tmp/docker_images/test1') }
  end

  context 'with ensure => present and image_tag => precise' do
    let(:params) { { 'ensure' => 'present', 'image_tag' => 'precise' } }
    it { should contain_exec('/usr/local/bin/update_docker_image.sh base:precise') }
  end

  context 'with ensure => present and image_digest => sha256:deadbeef' do
    let(:params) { { 'ensure' => 'present', 'image_digest' => 'sha256:deadbeef' } }
    it { should contain_exec('/usr/local/bin/update_docker_image.sh base@sha256:deadbeef') }
  end

  context 'with ensure => present and image_tag => precise and docker_file => Dockerfile' do
    let(:params) { { 'ensure' => 'present', 'image_tag' => 'precise', 'docker_file' => 'Dockerfile' } }
    it { should contain_exec('docker build -t base:precise - < Dockerfile') }
  end

  context 'with ensure => present and image_tag => precise and docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'ensure' => 'present', 'image_tag' => 'precise', 'docker_dir' => '/tmp/docker_images/test1' } }
    it { should contain_exec('docker build -t base:precise /tmp/docker_images/test1') }
  end

  context 'with docker_tar => /tmp/docker_tars/test1.tar' do
    let(:params) { { 'docker_tar' => '/tmp/docker_tars/test1.tar' } }
    it { should contain_exec('docker load -i /tmp/docker_tars/test1.tar') }
  end

  context 'with ensure => present and docker_tar => /tmp/docker_tars/test1.tar' do
    let(:params) { { 'ensure' => 'present', 'docker_tar' => '/tmp/docker_tars/test1.tar' } }
    it { should contain_exec('docker load -i /tmp/docker_tars/test1.tar') }
  end

  context 'with docker_file => Dockerfile and docker_tar => /tmp/docker_tars/test1.tar' do
    let(:params) { { 'docker_file' => 'Dockerfile', 'docker_tar' => '/tmp/docker_tars/test1.tar' }}
    it do
      expect {
        should have_exec_resource_count(1)
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with docker_tar => /tmp/docker_tars/test1.tar and docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'docker_tar' => '/tmp/docker_tars/test1.tar', 'docker_dir' => '/tmp/docker_images/test1' }}
    it do
      expect {
        should have_exec_resource_count(1)
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with image_digest => sha256:deadbeef and docker_file => Dockerfile' do
    let(:params) { { 'image_digest' => 'sha256:deadbeef', 'docker_file' => 'Dockerfile' }}
    it do
      expect {
        should have_exec_resource_count(1)
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with image_digest => sha256:deadbeef and docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'image_digest' => 'sha256:deadbeef', 'docker_dir' => '/tmp/docker_images/test1' }}
    it do
      expect {
        should have_exec_resource_count(1)
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with image_digest => sha256:deadbeef and docker_tar => /tmp/docker_tars/test1.tar' do
    let(:params) { { 'image_digest' => 'sha256:deadbeef', 'docker_tar' => '/tmp/docker_tars/test1.tar' }}
    it do
      expect {
        should have_exec_resource_count(1)
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with ensure => latest' do
    let(:params) { { 'ensure' => 'latest' } }
    it { should contain_exec("/usr/local/bin/update_docker_image.sh base") }
  end

  context 'with ensure => latest and image_tag => precise' do
    let(:params) { { 'ensure' => 'latest', 'image_tag' => 'precise' } }
    it { should contain_exec("/usr/local/bin/update_docker_image.sh base:precise") }
  end

  context 'with ensure => latest and image_digest => sha256:deadbeef' do
    let(:params) { { 'ensure' => 'latest', 'image_digest' => 'sha256:deadbeef' } }
    it { should contain_exec("/usr/local/bin/update_docker_image.sh base@sha256:deadbeef") }
  end

  context 'with an invalid image name' do
    let(:title) { 'with spaces' }
    it do
      expect {
        should contain_exec('/usr/local/bin/update_docker_image.sh with spaces')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with an invalid ensure value' do
    let(:params) { { 'ensure' => 'not present or absent' } }
    it do
      expect {
        should contain_exec('docker rmi base')
      }.to raise_error(Puppet::Error)
    end
  end
end
