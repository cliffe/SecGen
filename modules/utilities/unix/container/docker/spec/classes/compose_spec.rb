require 'spec_helper'

describe 'docker::compose', :type => :class do
  let(:facts) do
    {
      :kernel                    => 'Linux',
      :osfamily                  => 'Debian',
      :operatingsystem           => 'Ubuntu',
      :lsbdistid                 => 'Ubuntu',
      :lsbdistcodename           => 'maverick',
      :kernelrelease             => '3.8.0-29-generic',
      :operatingsystemrelease    => '10.04',
      :operatingsystemmajrelease => '10',
    }
  end

  it { is_expected.to compile }

  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_exec('Install Docker Compose 1.9.0').with(
      'path'    => '/usr/bin/',
      'cwd'     => '/tmp',
      'command' => 'curl -s -S -L  https://github.com/docker/compose/releases/download/1.9.0/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose-1.9.0',
      'creates' => '/usr/local/bin/docker-compose-1.9.0',
      'require' => 'Package[curl]'
    )}
    it { should contain_file('/usr/local/bin/docker-compose-1.9.0').with(
      'owner'   => 'root',
      'mode'    => '0755',
      'require' => 'Exec[Install Docker Compose 1.9.0]'
    )}
    it { should contain_file('/usr/local/bin/docker-compose').with(
      'ensure'   => 'link',
      'target'   => '/usr/local/bin/docker-compose-1.9.0',
      'require'  => 'File[/usr/local/bin/docker-compose-1.9.0]'
    )}
  end

  context 'with ensure => absent' do
    let (:params) { { :ensure => 'absent' } }
    it { should contain_file('/usr/local/bin/docker-compose-1.9.0').with_ensure('absent') }
    it { should contain_file('/usr/local/bin/docker-compose').with_ensure('absent') }
  end

  context 'when no proxy is provided' do
    let(:params) { {:version => '1.7.0'} }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
      'curl -s -S -L  https://github.com/docker/compose/releases/download/1.7.0/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose-1.7.0')
    }
  end

  context 'when proxy is provided' do
    let(:params) { {:proxy => 'http://proxy.example.org:3128/',
                    :version => '1.7.0'} }
    it { is_expected.to compile }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
      'curl -s -S -L --proxy http://proxy.example.org:3128/ https://github.com/docker/compose/releases/download/1.7.0/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose-1.7.0')
    }
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
      'curl -s -S -L --proxy http://user:password@proxy.example.org:3128/ https://github.com/docker/compose/releases/download/1.7.0/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose-1.7.0')
    }
  end

  context 'when proxy IP is provided' do
    let(:params) { {:proxy => 'http://10.10.10.10:3128/',
                    :version => '1.7.0'} }
    it { is_expected.to compile }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
      'curl -s -S -L --proxy http://10.10.10.10:3128/ https://github.com/docker/compose/releases/download/1.7.0/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose-1.7.0')
    }
  end
end
