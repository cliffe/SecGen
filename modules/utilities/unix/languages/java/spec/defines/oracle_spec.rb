require 'spec_helper'

oracle_url = 'http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz'

describe 'java::oracle', type: :define do
  context 'with CentOS 64-bit' do
    let(:facts) { { kernel: 'Linux', os: { family: 'RedHat', architecture: 'x86_64', name: 'CentOS', release: { full: '6.0' } } } }

    context 'when Oracle Java SE 6 JDK' do
      let(:params) { { ensure: 'present', version: '6', java_se: 'jdk' } }
      let(:title) { 'jdk6' }

      it { is_expected.to contain_archive('/tmp/jdk-6u45-linux-x64-rpm.bin') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 6').with_command('sh /tmp/jdk-6u45-linux-x64-rpm.bin -x; rpm --force -iv sun*.rpm; rpm --force -iv jdk*.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 6').that_requires('Archive[/tmp/jdk-6u45-linux-x64-rpm.bin]') }
    end

    context 'when Oracle Java SE 7 JDK' do
      let(:params) { { ensure: 'present', version: '7', java_se: 'jdk' } }
      let(:title) { 'jdk7' }

      it { is_expected.to contain_archive('/tmp/jdk-7u80-linux-x64.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 7').with_command('rpm --force -iv /tmp/jdk-7u80-linux-x64.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 7').that_requires('Archive[/tmp/jdk-7u80-linux-x64.rpm]') }
    end

    context 'when Oracle Java SE 8 JDK' do
      let(:params) { { ensure: 'present', version: '8', java_se: 'jdk' } }
      let(:title) { 'jdk8' }

      it { is_expected.to contain_archive('/tmp/jdk-8u131-linux-x64.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 8').with_command('rpm --force -iv /tmp/jdk-8u131-linux-x64.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 8').that_requires('Archive[/tmp/jdk-8u131-linux-x64.rpm]') }
    end

    context 'when Oracle Java SE 6 JRE' do
      let(:params) { { ensure: 'present', version: '6', java_se: 'jre' } }
      let(:title) { 'jre6' }

      it { is_expected.to contain_archive('/tmp/jre-6u45-linux-x64-rpm.bin') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 6').with_command('sh /tmp/jre-6u45-linux-x64-rpm.bin -x; rpm --force -iv sun*.rpm; rpm --force -iv jre*.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 6').that_requires('Archive[/tmp/jre-6u45-linux-x64-rpm.bin]') }
    end

    context 'when Oracle Java SE 7 JRE' do
      let(:params) { { ensure: 'present', version: '7', java_se: 'jre' } }
      let(:title) { 'jre7' }

      it { is_expected.to contain_archive('/tmp/jre-7u80-linux-x64.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 7').with_command('rpm --force -iv /tmp/jre-7u80-linux-x64.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 7').that_requires('Archive[/tmp/jre-7u80-linux-x64.rpm]') }
    end

    context 'when select Oracle Java SE 8 JRE' do
      let(:params) { { ensure: 'present', version: '8', java_se: 'jre' } }
      let(:title) { 'jre8' }

      it { is_expected.to contain_archive('/tmp/jre-8u131-linux-x64.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 8').with_command('rpm --force -iv /tmp/jre-8u131-linux-x64.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 8').that_requires('Archive[/tmp/jre-8u131-linux-x64.rpm]') }
    end

    context 'when passing URL to url parameter' do
      let(:params) do
        {
          ensure: 'present',
          version_major: '8u131',
          version_minor: 'b11',
          java_se: 'jdk',
          url: 'http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm',
          url_hash: 'ignored',
        }
      end
      let(:title) { 'jdk8' }

      it {
        is_expected.to contain_archive('/tmp/jdk-8u131-linux-x64.rpm')
          .with_source('http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm')
      }
    end

    context 'when passing a hash to url_hash parameter' do
      let(:params) do
        {
          ensure: 'present',
          version_major: '8u131',
          version_minor: 'b11',
          java_se: 'jdk',
          url_hash: 'abcdef01234567890',
        }
      end
      let(:title) { 'jdk8' }

      it { is_expected.to contain_archive('/tmp/jdk-8u131-linux-x64.rpm').with_source('http://download.oracle.com/otn-pub/java/jdk//8u131-b11/abcdef01234567890/jdk-8u131-linux-x64.rpm') }
    end
  end

  context 'when on CentOS 32-bit' do
    let(:facts) { { kernel: 'Linux', os: { family: 'RedHat', architecture: 'i386', name: 'CentOS', release: { full: '6.6' } } } }

    context 'when selecting Oracle Java SE 6 JDK on RedHat family, 32-bit' do
      let(:params) { { ensure: 'present', version: '6', java_se: 'jdk' } }
      let(:title) { 'jdk6' }

      it { is_expected.to contain_archive('/tmp/jdk-6u45-linux-i586-rpm.bin') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 6').with_command('sh /tmp/jdk-6u45-linux-i586-rpm.bin -x; rpm --force -iv sun*.rpm; rpm --force -iv jdk*.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 6').that_requires('Archive[/tmp/jdk-6u45-linux-i586-rpm.bin]') }
    end

    context 'when selecting Oracle Java SE 7 JDK on RedHat family, 32-bit' do
      let(:params) { { ensure: 'present', version: '7', java_se: 'jdk' } }
      let(:title) { 'jdk7' }

      it { is_expected.to contain_archive('/tmp/jdk-7u80-linux-i586.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 7').with_command('rpm --force -iv /tmp/jdk-7u80-linux-i586.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 7').that_requires('Archive[/tmp/jdk-7u80-linux-i586.rpm]') }
    end

    context 'when selecting Oracle Java SE 8 JDK on RedHat family, 32-bit' do
      let(:params) { { ensure: 'present', version: '8', java_se: 'jdk' } }
      let(:title) { 'jdk8' }

      it { is_expected.to contain_archive('/tmp/jdk-8u131-linux-i586.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 8').with_command('rpm --force -iv /tmp/jdk-8u131-linux-i586.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 8').that_requires('Archive[/tmp/jdk-8u131-linux-i586.rpm]') }
    end

    context 'when selecting Oracle Java SE 6 JRE on RedHat family, 32-bit' do
      let(:params) { { ensure: 'present', version: '6', java_se: 'jre' } }
      let(:title) { 'jdk6' }

      it { is_expected.to contain_archive('/tmp/jre-6u45-linux-i586-rpm.bin') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 6').with_command('sh /tmp/jre-6u45-linux-i586-rpm.bin -x; rpm --force -iv sun*.rpm; rpm --force -iv jre*.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 6').that_requires('Archive[/tmp/jre-6u45-linux-i586-rpm.bin]') }
    end

    context 'when select Oracle Java SE 7 JRE on RedHat family, 32-bit' do
      let(:params) { { ensure: 'present', version: '7', java_se: 'jre' } }
      let(:title) { 'jdk7' }

      it { is_expected.to contain_archive('/tmp/jre-7u80-linux-i586.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 7').with_command('rpm --force -iv /tmp/jre-7u80-linux-i586.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 7').that_requires('Archive[/tmp/jre-7u80-linux-i586.rpm]') }
    end

    context 'when select Oracle Java SE 8 JRE on RedHat family, 32-bit' do
      let(:params) { { ensure: 'present', version: '8', java_se: 'jre' } }
      let(:title) { 'jdk8' }

      it { is_expected.to contain_archive('/tmp/jre-8u131-linux-i586.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 8').with_command('rpm --force -iv /tmp/jre-8u131-linux-i586.rpm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 8').that_requires('Archive[/tmp/jre-8u131-linux-i586.rpm]') }
    end
  end

  context 'with Ubuntu 64-bit' do
    let(:facts) { { kernel: 'Linux', os: { family: 'Debian', architecture: 'amd64', name: 'Ubuntu', release: { full: '16.04' } } } }

    context 'when Oracle Java SE 6 JDK' do
      let(:params) { { ensure: 'present', version: '6', java_se: 'jdk' } }
      let(:title) { 'jdk6' }

      it { is_expected.to contain_archive('/tmp/jdk-6u45-linux-x64.tar.gz') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 6').with_command('tar -zxf /tmp/jdk-6u45-linux-x64.tar.gz -C /usr/lib/jvm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 6').that_requires('Archive[/tmp/jdk-6u45-linux-x64.tar.gz]') }
    end

    context 'with Oracle Java SE 7 JDK' do
      let(:params) { { ensure: 'present', version: '7', java_se: 'jdk' } }
      let(:title) { 'jdk7' }

      it { is_expected.to contain_archive('/tmp/jdk-7u80-linux-x64.tar.gz') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 7').with_command('tar -zxf /tmp/jdk-7u80-linux-x64.tar.gz -C /usr/lib/jvm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 7').that_requires('Archive[/tmp/jdk-7u80-linux-x64.tar.gz]') }
    end

    context 'with Oracle Java SE 8 JDK' do
      let(:params) { { ensure: 'present', version: '8', java_se: 'jdk' } }
      let(:title) { 'jdk8' }

      it { is_expected.to contain_archive('/tmp/jdk-8u131-linux-x64.tar.gz') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 8').with_command('tar -zxf /tmp/jdk-8u131-linux-x64.tar.gz -C /usr/lib/jvm') }
      it { is_expected.to contain_exec('Install Oracle java_se jdk 8').that_requires('Archive[/tmp/jdk-8u131-linux-x64.tar.gz]') }
    end

    context 'with Oracle Java SE 6 JRE' do
      let(:params) { { ensure: 'present', version: '6', java_se: 'jre' } }
      let(:title) { 'jre6' }

      it { is_expected.to contain_archive('/tmp/jre-6u45-linux-x64.tar.gz') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 6').with_command('tar -zxf /tmp/jre-6u45-linux-x64.tar.gz -C /usr/lib/jvm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 6').that_requires('Archive[/tmp/jre-6u45-linux-x64.tar.gz]') }
    end

    context 'when Oracle Java SE 7 JRE' do
      let(:params) { { ensure: 'present', version: '7', java_se: 'jre' } }
      let(:title) { 'jre7' }

      it { is_expected.to contain_archive('/tmp/jre-7u80-linux-x64.tar.gz') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 7').with_command('tar -zxf /tmp/jre-7u80-linux-x64.tar.gz -C /usr/lib/jvm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 7').that_requires('Archive[/tmp/jre-7u80-linux-x64.tar.gz]') }
    end

    context 'when Oracle Java SE 8 JRE' do
      let(:params) { { ensure: 'present', version: '8', java_se: 'jre' } }
      let(:title) { 'jre8' }

      it { is_expected.to contain_archive('/tmp/jre-8u131-linux-x64.tar.gz') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 8').with_command('tar -zxf /tmp/jre-8u131-linux-x64.tar.gz -C /usr/lib/jvm') }
      it { is_expected.to contain_exec('Install Oracle java_se jre 8').that_requires('Archive[/tmp/jre-8u131-linux-x64.tar.gz]') }
    end

    context 'when passing URL to url parameter' do
      let(:params) { { ensure: 'present', version_major: '8u131', version_minor: 'b11', java_se: 'jdk', url: oracle_url.to_s } }
      let(:title) { 'jdk8' }

      it { is_expected.to contain_archive('/tmp/jdk-8u131-linux-x64.tar.gz') }
    end
  end
  describe 'incompatible OSes' do
    [
      {
        # C14706
        kernel: 'Windows',
        os: {
          family: 'Windows',
          name: 'Windows',
          release: {
            full: '8.1',
          },
        },
      },
      {
        # C14707
        kernel: 'Darwin',
        os: {
          family: 'Darwin',
          name: 'Darwin',
          release: {
            full: '13.3.0',
          },
        },
      },
      {
        # C14708
        kernel: 'AIX',
        os: {
          family: 'AIX',
          name: 'AIX',
          release: {
            full: '7100-02-00-000',
          },
        },
      },
      {
        # C14709
        kernel: 'AIX',
        os: {
          family: 'AIX',
          name: 'AIX',
          release: {
            full: '6100-07-04-1216',
          },
        },
      },
      {
        # C14710
        kernel: 'AIX',
        os: {
          family: 'AIX',
          name: 'AIX',
          release: {
            full: '5300-12-01-1016',
          },
        },
      },
    ].each do |facts|
      let(:facts) { facts }
      let(:title) { 'jdk' }

      it "is_expected.to fail on #{facts[:os][:name]} #{facts[:os][:release][:full]}" do
        expect { catalogue }.to raise_error Puppet::Error, %r{unsupported platform}
      end
    end
  end
end
