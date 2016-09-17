require 'spec_helper'

describe 'java::oracle', :type => :define do
    context 'On CentOS 64-bit' do
      let(:facts) { {:kernel => 'Linux', :architecture => 'x86_64', :osfamily => 'RedHat', :operatingsystem => 'CentOS', :operatingsystemrelease => '6.6', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)'} }

      context 'Oracle Java SE 6 JDK' do
      let(:params) { {:ensure => 'present', :version => '6', :java_se => 'jdk'} }
      let :title do 'jdk6' end
        it { should contain_archive('/tmp/jdk-6u45-linux-x64-rpm.bin')}
        it { should contain_exec('Install Oracle java_se jdk 6').with_command('sh /tmp/jdk-6u45-linux-x64-rpm.bin -x; rpm --force -iv sun*.rpm; rpm --force -iv jdk*.rpm') }
      end

      context 'Oracle Java SE 7 JDK' do
        let(:params) { {:ensure => 'present', :version => '7', :java_se => 'jdk'} }
        let :title do 'jdk7' end
          it { should contain_archive('/tmp/jdk-7u80-linux-x64.rpm')}
          it { should contain_exec('Install Oracle java_se jdk 7').with_command('rpm --force -iv /tmp/jdk-7u80-linux-x64.rpm') }
      end

    context 'Oracle Java SE 8 JDK' do
      let(:params) { {:ensure => 'present', :version => '8', :java_se => 'jdk'} }
      let :title do 'jdk8' end
        it { should contain_archive('/tmp/jdk-8u51-linux-x64.rpm')}
        it { should contain_exec('Install Oracle java_se jdk 8').with_command('rpm --force -iv /tmp/jdk-8u51-linux-x64.rpm') }
    end

    context 'Oracle Java SE 6 JRE' do
      let(:params) { {:ensure => 'present', :version => '6', :java_se => 'jre'} }
      let :title do 'jre6' end
        it { should contain_archive('/tmp/jre-6u45-linux-x64-rpm.bin')}
        it { should contain_exec('Install Oracle java_se jre 6').with_command('sh /tmp/jre-6u45-linux-x64-rpm.bin -x; rpm --force -iv sun*.rpm; rpm --force -iv jre*.rpm') }
    end

    context 'Oracle Java SE 7 JRE' do
      let(:params) { {:ensure => 'present', :version => '7', :java_se => 'jre'} }
      let :title do 'jre7' end
        it { should contain_archive('/tmp/jre-7u80-linux-x64.rpm')}
        it { should contain_exec('Install Oracle java_se jre 7').with_command('rpm --force -iv /tmp/jre-7u80-linux-x64.rpm') }
    end

    context 'select Oracle Java SE 8 JRE' do
      let(:params) { {:ensure => 'present', :version => '8', :java_se => 'jre'} }
      let :title do 'jre8' end
        it { should contain_archive('/tmp/jre-8u51-linux-x64.rpm')}
        it { should contain_exec('Install Oracle java_se jre 8').with_command('rpm --force -iv /tmp/jre-8u51-linux-x64.rpm') }
    end

  end

  context 'On CentOS 32-bit' do
    let(:facts) { {:kernel => 'Linux', :architecture => 'i386', :osfamily => 'RedHat', :operatingsystem => 'CentOS', :operatingsystemrelease => '6.6', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)'} }

    context 'select Oracle Java SE 6 JDK on RedHat family, 32-bit' do
      let(:params) { {:ensure => 'present', :version => '6', :java_se => 'jdk'} }
      let :title do 'jdk6' end
        it { should contain_archive('/tmp/jdk-6u45-linux-i586-rpm.bin')}
        it { should contain_exec('Install Oracle java_se jdk 6').with_command('sh /tmp/jdk-6u45-linux-i586-rpm.bin -x; rpm --force -iv sun*.rpm; rpm --force -iv jdk*.rpm') }
    end

    context 'select Oracle Java SE 7 JDK on RedHat family, 32-bit' do
      let(:params) { {:ensure => 'present', :version => '7', :java_se => 'jdk'} }
      let :title do 'jdk7' end
        it { should contain_archive('/tmp/jdk-7u80-linux-i586.rpm')}
        it { should contain_exec('Install Oracle java_se jdk 7').with_command('rpm --force -iv /tmp/jdk-7u80-linux-i586.rpm') }
    end

    context 'select Oracle Java SE 8 JDK on RedHat family, 32-bit' do
      let(:params) { {:ensure => 'present', :version => '8', :java_se => 'jdk'} }
      let :title do 'jdk8' end
        it { should contain_archive('/tmp/jdk-8u51-linux-i586.rpm')}
        it { should contain_exec('Install Oracle java_se jdk 8').with_command('rpm --force -iv /tmp/jdk-8u51-linux-i586.rpm') }
    end

    context 'select Oracle Java SE 6 JRE on RedHat family, 32-bit' do
      let(:params) { {:ensure => 'present', :version => '6', :java_se => 'jre'} }
      let :title do 'jdk6' end
        it { should contain_archive('/tmp/jre-6u45-linux-i586-rpm.bin')}
        it { should contain_exec('Install Oracle java_se jre 6').with_command('sh /tmp/jre-6u45-linux-i586-rpm.bin -x; rpm --force -iv sun*.rpm; rpm --force -iv jre*.rpm') }
    end

    context 'select Oracle Java SE 7 JRE on RedHat family, 32-bit' do
      let(:params) { {:ensure => 'present', :version => '7', :java_se => 'jre'} }
      let :title do 'jdk7' end
        it { should contain_archive('/tmp/jre-7u80-linux-i586.rpm')}
        it { should contain_exec('Install Oracle java_se jre 7').with_command('rpm --force -iv /tmp/jre-7u80-linux-i586.rpm') }
    end

    context 'select Oracle Java SE 8 JRE on RedHat family, 32-bit' do
      let(:params) { {:ensure => 'present', :version => '8', :java_se => 'jre'} }
      let :title do 'jdk8' end
        it { should contain_archive('/tmp/jre-8u51-linux-i586.rpm')}
        it { should contain_exec('Install Oracle java_se jre 8').with_command('rpm --force -iv /tmp/jre-8u51-linux-i586.rpm') }
    end
  end

  describe 'incompatible OSs' do
    [
      {
        # C14706
        :osfamily               => 'windows',
        :operatingsystem        => 'windows',
        :operatingsystemrelease => '8.1',
        :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)',
      },
      {
        # C14707
        :osfamily               => 'Darwin',
        :operatingsystem        => 'Darwin',
        :operatingsystemrelease => '13.3.0',
        :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)',
      },
      {
        # C14708
        :osfamily               => 'AIX',
        :operatingsystem        => 'AIX',
        :operatingsystemrelease => '7100-02-00-000',
        :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)',
      },
      {
        # C14708
        :osfamily               => 'AIX',
        :operatingsystem        => 'AIX',
        :operatingsystemrelease => '6100-07-04-1216',
        :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)',
      },
      {
        # C14708
        :osfamily               => 'AIX',
        :operatingsystem        => 'AIX',
        :operatingsystemrelease => '5300-12-01-1016',
        :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)',
      },
    ].each do |facts|
      let(:facts) { facts }
      let :title do 'jdk' end
      it "should fail on #{facts[:operatingsystem]} #{facts[:operatingsystemrelease]}" do
        expect { catalogue }.to raise_error Puppet::Error, /unsupported platform/
      end
    end
  end
end
