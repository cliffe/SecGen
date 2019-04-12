require 'spec_helper'

describe 'apache::mod::ssl', :type => :class do
  it_behaves_like "a mod class, without including apache"
  context 'on an unsupported OS' do
    let :facts do
      {
        :osfamily               => 'Magic',
        :operatingsystemrelease => '0',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'Magic',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { expect { catalogue }.to raise_error(Puppet::Error, /Unsupported osfamily:/) }
  end

  context 'on a RedHat OS' do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class('apache::params') }
    it { is_expected.to contain_apache__mod('ssl') }
    it { is_expected.to contain_package('mod_ssl') }
    context 'with a custom package_name parameter' do
      let :params do
        { :package_name => 'httpd24-mod_ssl' }
      end
      it { is_expected.to contain_class('apache::params') }
      it { is_expected.to contain_apache__mod('ssl') }
      it { is_expected.to contain_package('httpd24-mod_ssl') }
      it { is_expected.not_to contain_package('mod_ssl') }
    end
  end

  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class('apache::params') }
    it { is_expected.to contain_apache__mod('ssl') }
    it { is_expected.not_to contain_package('libapache2-mod-ssl') }
  end

  context 'on a FreeBSD OS' do
    let :facts do
      {
        :osfamily               => 'FreeBSD',
        :operatingsystemrelease => '9',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'FreeBSD',
        :id                     => 'root',
        :kernel                 => 'FreeBSD',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class('apache::params') }
    it { is_expected.to contain_apache__mod('ssl') }
  end

  context 'on a Gentoo OS' do
    let :facts do
      {
        :osfamily               => 'Gentoo',
        :operatingsystem        => 'Gentoo',
        :operatingsystemrelease => '3.16.1-gentoo',
        :concat_basedir         => '/dne',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class('apache::params') }
    it { is_expected.to contain_apache__mod('ssl') }
  end

  context 'on a Suse OS' do
    let :facts do
      {
        :osfamily               => 'Suse',
        :operatingsystem        => 'SLES',
        :operatingsystemrelease => '12',
        :concat_basedir         => '/dne',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class('apache::params') }
    it { is_expected.to contain_apache__mod('ssl') }
  end
  # Template config doesn't vary by distro
  context "on all distros" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystem        => 'CentOS',
        :operatingsystemrelease => '6',
        :kernel                 => 'Linux',
        :id                     => 'root',
        :concat_basedir         => '/dne',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    context 'not setting ssl_pass_phrase_dialog' do
      it { is_expected.to contain_file('ssl.conf').with_content(/^  SSLPassPhraseDialog builtin$/)}
    end

    context "with Apache version < 2.4" do
      let :params do
        {
          :apache_version => '2.2',
        }
      end
      context 'ssl_compression with default value' do
        it { is_expected.not_to contain_file('ssl.conf').with_content(/^  SSLCompression Off$/)}
      end

      context 'setting ssl_compression to true' do
        let :params do
          {
            :ssl_compression => true,
          }
        end
        it { is_expected.not_to contain_file('ssl.conf').with_content(/^  SSLCompression On$/)}
      end
      context 'setting ssl_stapling to true' do
        let :params do
          {
            :ssl_stapling => true,
          }
        end
        it { is_expected.not_to contain_file('ssl.conf').with_content(/^  SSLUseStapling/)}
      end
    end
    context "with Apache version >= 2.4" do
      let :params do
        {
          :apache_version => '2.4',
        }
      end
      context 'ssl_compression with default value' do
        it { is_expected.not_to contain_file('ssl.conf').with_content(/^  SSLCompression Off$/)}
      end

      context 'setting ssl_compression to true' do
        let :params do
          {
            :apache_version => '2.4',
            :ssl_compression => true,
          }
        end
        it { is_expected.to contain_file('ssl.conf').with_content(/^  SSLCompression On$/)}
      end
      context 'setting ssl_stapling to true' do
        let :params do
          {
            :apache_version => '2.4',
            :ssl_stapling => true,
          }
        end
        it { is_expected.to contain_file('ssl.conf').with_content(/^  SSLUseStapling On$/)}
      end
      context 'setting ssl_stapling_return_errors to true' do
        let :params do
          {
            :apache_version => '2.4',
            :ssl_stapling_return_errors => true,
          }
        end
        it { is_expected.to contain_file('ssl.conf').with_content(/^  SSLStaplingReturnResponderErrors On$/)}
      end
    end

    context 'setting ssl_pass_phrase_dialog' do
      let :params do
        {
          :ssl_pass_phrase_dialog => 'exec:/path/to/program',
        }
      end
      it { is_expected.to contain_file('ssl.conf').with_content(/^  SSLPassPhraseDialog exec:\/path\/to\/program$/)}
    end

    context 'setting ssl_random_seed_bytes' do
      let :params do
        {
          :ssl_random_seed_bytes => '1024',
        }
      end
      it { is_expected.to contain_file('ssl.conf').with_content(%r{^  SSLRandomSeed startup file:/dev/urandom 1024$})}
    end

    context 'setting ssl_openssl_conf_cmd' do
      let :params do
        {
          :ssl_openssl_conf_cmd => 'DHParameters "foo.pem"',
        }
      end
      it { is_expected.to contain_file('ssl.conf').with_content(/^\s+SSLOpenSSLConfCmd DHParameters "foo.pem"$/)}
    end

    context 'setting ssl_mutex' do
      let :params do
        {
          :ssl_mutex => 'posixsem',
        }
      end
      it { is_expected.to contain_file('ssl.conf').with_content(%r{^  SSLMutex posixsem$})}
    end
  end
end
