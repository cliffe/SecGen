require 'spec_helper'

describe 'python::pip', :type => :define do
  let (:title) { 'rpyc' }
  context "on Debian OS" do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :lsbdistcodename        => 'squeeze',
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
      }
    end

    describe "virtualenv as" do
      context "fails with non qualified path" do
        let (:params) {{ :virtualenv => "venv" }}
        it { is_expected.to raise_error(/"venv" is not an absolute path./) }
      end
      context "suceeds with qualified path" do
        let (:params) {{ :virtualenv => "/opt/venv" }}
        it { is_expected.to contain_exec("pip_install_rpyc").with_cwd('/opt/venv') }
      end
      context "defaults to system" do
        let (:params) {{ }}
        it { is_expected.to contain_exec("pip_install_rpyc").with_cwd('/') }
      end
    end

    describe "proxy as" do
      context "defaults to empty" do
        let (:params) {{ }}
        it { should_not contain_exec("pip_install_rpyc").with_command(/--proxy/) }
      end
      context "does not add proxy to search command if set to latest and proxy is unset" do
        let (:params) {{ :ensure => 'latest' }}
        it { should_not contain_exec("pip_install_rpyc").with_command(/--proxy/) }
        it { is_expected.to contain_exec("pip_install_rpyc").without_unless(/--proxy/) }
      end
      context "adds proxy to install command if proxy set" do
        let (:params) {{ :proxy => "http://my.proxy:3128" }}
        it { is_expected.to contain_exec("pip_install_rpyc").with_command("pip wheel --help > /dev/null 2>&1 && { pip wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; { pip --log /tmp/pip.log install $wheel_support_flag  --proxy=http://my.proxy:3128   rpyc || pip --log /tmp/pip.log install  --proxy=http://my.proxy:3128   rpyc ;}") }
      end
      context "adds proxy to search command if set to latest" do
        let (:params) {{ :proxy => "http://my.proxy:3128", :ensure => 'latest' }}
        it { is_expected.to contain_exec("pip_install_rpyc").with_command("pip wheel --help > /dev/null 2>&1 && { pip wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; { pip --log /tmp/pip.log install --upgrade $wheel_support_flag  --proxy=http://my.proxy:3128   rpyc || pip --log /tmp/pip.log install --upgrade  --proxy=http://my.proxy:3128   rpyc ;}") }
        it { is_expected.to contain_exec("pip_install_rpyc").with_unless('pip search  --proxy=http://my.proxy:3128 rpyc | grep -i INSTALLED.*latest') }
      end
    end

    describe 'index as' do
      context 'defaults to empty' do
        let (:params) {{ }}
        it { should_not contain_exec('pip_install_rpyc').with_command(/--index-url/) }
      end
      context 'adds index to install command if index set' do
        let (:params) {{ :index => 'http://www.example.com/simple/' }}
        it { is_expected.to contain_exec('pip_install_rpyc').with_command("pip wheel --help > /dev/null 2>&1 && { pip wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; { pip --log /tmp/pip.log install $wheel_support_flag --index-url=http://www.example.com/simple/    rpyc || pip --log /tmp/pip.log install --index-url=http://www.example.com/simple/    rpyc ;}") }
      end
      context 'adds index to search command if set to latest' do
        let (:params) {{ :index => 'http://www.example.com/simple/', :ensure => 'latest' }}
        it { is_expected.to contain_exec('pip_install_rpyc').with_command("pip wheel --help > /dev/null 2>&1 && { pip wheel --version > /dev/null 2>&1 || wheel_support_flag='--no-use-wheel'; } ; { pip --log /tmp/pip.log install --upgrade $wheel_support_flag --index-url=http://www.example.com/simple/    rpyc || pip --log /tmp/pip.log install --upgrade --index-url=http://www.example.com/simple/    rpyc ;}") }
      end
    end

  end
end
