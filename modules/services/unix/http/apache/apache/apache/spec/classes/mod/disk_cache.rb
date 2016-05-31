require 'spec_helper'

describe 'apache::mod::disk_cache', :type => :class do
  let :pre_condition do
    'include apache'
  end
  context "on a Debian OS", :compile do
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
        :is_pe                  => false,
      }
    end
    context "with Apache version < 2.4" do
      let :params do
        {
          :apache_version => '2.2',
        }
      end

      it { is_expected.to contain_apache__mod("disk_cache") }
      it { is_expected.to contain_file("disk_cache.conf").with(:content => /CacheEnable disk /\nCacheRoot \"\/var\/cache\/apache2\/mod_disk_cache\"\nCacheDirLevels 2\nCacheDirLength 1/) }
    end
    context "with Apache version >= 2.4" do
      let :params do
        {
          :apache_version => '2.4',
        }
      end

      it { is_expected.to contain_apache__mod("cache_disk") }
      it { is_expected.to contain_file("disk_cache.conf").with(:content => /CacheEnable disk /\nCacheRoot \"\/var\/cache\/apache2\/mod_cache_disk\"\nCacheDirLevels 2\nCacheDirLength 1/) }
    end
  end

  context "on a RedHat 6-based OS", :compile do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '6',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    context "with Apache version < 2.4" do
      let :params do
        {
          :apache_version => '2.2',
        }
      end

      it { is_expected.to contain_apache__mod("disk_cache") }
      it { is_expected.to contain_file("disk_cache.conf").with(:content => /CacheEnable disk /\nCacheRoot \"\/var\/cache\/httpd\/proxy\"\nCacheDirLevels 2\nCacheDirLength 1/) }
    end
    context "with Apache version >= 2.4" do
      let :params do
        {
          :apache_version => '2.4',
        }
      end

      it { is_expected.to contain_apache__mod("cache_disk") }
      it { is_expected.to contain_file("disk_cache.conf").with(:content => /CacheEnable disk /\nCacheRoot \"\/var\/cache\/httpd\/proxy\"\nCacheDirLevels 2\nCacheDirLength 1/) }
    end
  end
  context "on a FreeBSD OS", :compile do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'FreeBSD',
        :osfamily               => 'FreeBSD',
        :operatingsystem        => 'FreeBSD',
        :operatingsystemrelease => '10',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    context "with Apache version < 2.4" do
      let :params do
        {
          :apache_version => '2.2',
        }
      end

      it { is_expected.to contain_apache__mod("disk_cache") }
      it { is_expected.to contain_file("disk_cache.conf").with(:content => /CacheEnable disk /\nCacheRoot \"\/var\/cache\/mod_cache_disk\"\nCacheDirLevels 2\nCacheDirLength 1/) }
    end
    context "with Apache version >= 2.4" do
      let :params do
        {
          :apache_version => '2.4',
        }
      end

      it { is_expected.to contain_apache__mod("cache_disk") }
      it { is_expected.to contain_file("disk_cache.conf").with(:content => /CacheEnable disk /\nCacheRoot \"\/var\/cache\/mod_cache_disk\"\nCacheDirLevels 2\nCacheDirLength 1/) }
    end
  end
end
