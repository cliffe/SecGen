require 'spec_helper'

describe 'docker::compose', :type => :class do
  let(:facts) do
    {
      :architecture              => 'amd64',
      :osfamily                  => 'windows',
      :operatingsystem           => 'windows',
      :kernel                    => 'windows',
      :kernelrelease             => '10.0.14393',
      :operatingsystemrelease    => '2016',
      :operatingsystemmajrelease => '2016',
      :os                        => { :family => 'windows', :name => 'windows', :release => { :major => '2016', :full => '2016' } }
    }
  end

  it { is_expected.to compile }

  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_exec('Install Docker Compose 1.21.2').with(
      'path'    => ['c:/Windows/Temp/', 'C:/Program Files/Docker/'],
      'command' => '& C:/Windows/Temp/download_docker_compose.ps1',
      'provider' => 'powershell',
      'creates' => 'C:/Program Files/Docker/docker-compose-1.21.2.exe'
    )}
    it { should contain_file('C:/Program Files/Docker/docker-compose-1.21.2.exe').with(
      'owner'   => 'Administrator',
      'mode'    => '0755',
      'require' => 'Exec[Install Docker Compose 1.21.2]'
    )}
    it { should contain_file('C:/Program Files/Docker/docker-compose.exe').with(
      'ensure'   => 'link',
      'target'   => 'C:/Program Files/Docker/docker-compose-1.21.2.exe',
      'require'  => 'File[C:/Program Files/Docker/docker-compose-1.21.2.exe]'
    )}
  end

  context 'with ensure => absent' do
    let (:params) { { :ensure => 'absent' } }
    it { should contain_file('C:/Program Files/Docker/docker-compose-1.21.2.exe').with_ensure('absent') }
    it { should contain_file('C:/Program Files/Docker/docker-compose.exe').with_ensure('absent') }
  end

  context 'when no proxy is provided' do
    let(:params) { {:version => '1.7.0'} }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
      '& C:/Windows/Temp/download_docker_compose.ps1')
    }
  end

  context 'when proxy is provided' do
    let(:params) { {:proxy => 'http://proxy.example.org:3128/',
                    :version => '1.7.0'} }
    it { is_expected.to compile }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
      '& C:/Windows/Temp/download_docker_compose.ps1')
    }
    it { should contain_file('C:/Windows/Temp/download_docker_compose.ps1').with_content(/WebProxy/) }
  end

  context 'when proxy is not a http proxy' do
    let(:params)  { {:proxy => 'this is not a URL'} }
    it do
      expect {
        is_expected.to compile
      }.to raise_error(/does not match/)
    end
  end

  context 'when proxy contains username and password' do
    let(:params)  { {:proxy => 'http://user:password@proxy.example.org:3128/',
                     :version => '1.7.0'} }
    it { is_expected.to compile }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
      '& C:/Windows/Temp/download_docker_compose.ps1')
    }
    it { should contain_file('C:/Windows/Temp/download_docker_compose.ps1').with_content(/Credentials/) }
  end

  context 'when proxy IP is provided' do
    let(:params) { {:proxy => 'http://10.10.10.10:3128/',
                    :version => '1.7.0'} }
    it { is_expected.to compile }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
      '& C:/Windows/Temp/download_docker_compose.ps1')
    }
    it { should contain_file('C:/Windows/Temp/download_docker_compose.ps1').with_content(/10.10.10.10:3128/) }
  end
end
