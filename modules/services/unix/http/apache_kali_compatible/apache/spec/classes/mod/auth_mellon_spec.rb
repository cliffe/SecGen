require 'spec_helper'

describe 'apache::mod::auth_mellon', :type => :class do
  it_behaves_like "a mod class, without including apache"

  context "default configuration with parameters" do
    context "on a Debian OS" do
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
          :fqdn                   => 'test.example.com',
          :is_pe                  => false,
        }
      end
      describe 'with no parameters' do
        it { should contain_apache__mod('auth_mellon') }
        it { should contain_package('libapache2-mod-auth-mellon') }
        it { should contain_file('auth_mellon.conf').with_path('/etc/apache2/mods-available/auth_mellon.conf') }
        it { should contain_file('auth_mellon.conf').with_content("MellonPostDirectory \"\/var\/cache\/apache2\/mod_auth_mellon\/\"\n") }
      end
      describe 'with parameters' do
        let :params do
          { :mellon_cache_size => '200',
            :mellon_cache_entry_size => '2010',
            :mellon_lock_file => '/tmp/junk',
            :mellon_post_directory => '/tmp/post',
            :mellon_post_ttl => '5',
            :mellon_post_size => '8',
            :mellon_post_count => '10'
          }
        end
        it { should contain_file('auth_mellon.conf').with_content(/^MellonCacheSize\s+200$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonCacheEntrySize\s+2010$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonLockFile\s+"\/tmp\/junk"$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonPostDirectory\s+"\/tmp\/post"$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonPostTTL\s+5$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonPostSize\s+8$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonPostCount\s+10$/) }
      end

    end
    context "on a RedHat OS" do
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :fqdn                   => 'test.example.com',
          :is_pe                  => false,
        }
      end
      describe 'with no parameters' do
        it { should contain_apache__mod('auth_mellon') }
        it { should contain_package('mod_auth_mellon') }
        it { should contain_file('auth_mellon.conf').with_path('/etc/httpd/conf.d/auth_mellon.conf') }
        it { should contain_file('auth_mellon.conf').with_content("MellonCacheSize 100\nMellonLockFile \"/run/mod_auth_mellon/lock\"\n") }
      end
      describe 'with parameters' do
        let :params do
          { :mellon_cache_size => '200',
            :mellon_cache_entry_size => '2010',
            :mellon_lock_file => '/tmp/junk',
            :mellon_post_directory => '/tmp/post',
            :mellon_post_ttl => '5',
            :mellon_post_size => '8',
            :mellon_post_count => '10'
          }
        end
        it { should contain_file('auth_mellon.conf').with_content(/^MellonCacheSize\s+200$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonCacheEntrySize\s+2010$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonLockFile\s+"\/tmp\/junk"$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonPostDirectory\s+"\/tmp\/post"$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonPostTTL\s+5$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonPostSize\s+8$/) }
        it { should contain_file('auth_mellon.conf').with_content(/^MellonPostCount\s+10$/) }
      end
    end
  end
end
