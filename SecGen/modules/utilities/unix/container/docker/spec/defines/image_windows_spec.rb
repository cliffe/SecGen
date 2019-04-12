require 'spec_helper'

describe 'docker::image', :type => :define do
  let(:title) { 'base' }
  let(:facts) { {
      :architecture              => 'amd64',
      :osfamily                  => 'windows',
      :operatingsystem           => 'windows',
      :kernelrelease             => '10.0.14393',
      :operatingsystemrelease    => '2016',
      :operatingsystemmajrelease => '2016',
      :os                        => { :family => 'windows', :name => 'windows', :release => { :major => '2016', :full => '2016' } }
  } }
  context 'with ensure => present' do
      let(:params) { { 'ensure' => 'present' } }
      it { should contain_file('C:/Windows/Temp/update_docker_image.ps1') }
      it { should contain_exec('& C:/Windows/Temp/update_docker_image.ps1 base') }
  end

  context 'with docker_file => Dockerfile' do
      let(:params) { { 'docker_file' => 'Dockerfile' }}
      it { should contain_exec('Get-Content Dockerfile | docker build -t base -') }
    end

    context 'with ensure => present and docker_file => Dockerfile' do
        let(:params) { { 'ensure' => 'present', 'docker_file' => 'Dockerfile' } }
        it { should contain_exec('Get-Content Dockerfile | docker build -t base -') }
    end

    context 'with ensure => present and image_tag => nanoserver' do
        let(:params) { { 'ensure' => 'present', 'image_tag' => 'nanoserver' } }
        it { should contain_exec('& C:/Windows/Temp/update_docker_image.ps1 base:nanoserver') }
    end

    context 'with ensure => present and image_digest => sha256:deadbeef' do
        let(:params) { { 'ensure' => 'present', 'image_digest' => 'sha256:deadbeef' } }
        it { should contain_exec('& C:/Windows/Temp/update_docker_image.ps1 base@sha256:deadbeef') }
    end

    context 'with ensure => present and image_tag => nanoserver and docker_file => Dockerfile' do
        let(:params) { { 'ensure' => 'present', 'image_tag' => 'nanoserver', 'docker_file' => 'Dockerfile' } }
        it { should contain_exec('Get-Content Dockerfile | docker build -t base:nanoserver -') }
    end
    
    context 'with ensure => latest' do
        let(:params) { { 'ensure' => 'latest' } }
        it { should contain_exec("& C:/Windows/Temp/update_docker_image.ps1 base") }
    end

end