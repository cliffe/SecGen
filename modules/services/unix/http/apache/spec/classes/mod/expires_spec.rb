require 'spec_helper'

describe 'apache::mod::expires', :type => :class do
  it_behaves_like "a mod class, without including apache"

  context "with expires active", :compile do
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
    it { is_expected.to contain_apache__mod("expires") }
    it { is_expected.to contain_file("expires.conf").with(:content => /ExpiresActive On\n/) }
  end
  context "with expires default", :compile do
    let :pre_condition do
      'class { apache: default_mods => false }'
    end
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '7',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    let :params do
      {
        'expires_default' => 'access plus 1 month'
      }
    end
    it { is_expected.to contain_apache__mod("expires") }
    it { is_expected.to contain_file("expires.conf").with_content(
        "ExpiresActive On\n" \
        "ExpiresDefault \"access plus 1 month\"\n"
      )
    }
  end
  context "with expires by type", :compile do
    let :pre_condition do
      'class { apache: default_mods => false }'
    end
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '7',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    let :params do
      {
        'expires_by_type' => [
          { 'text/json' => 'mod plus 1 day' },
          { 'text/html' => 'access plus 1 year' },
        ]
      }
    end
    it { is_expected.to contain_apache__mod("expires") }
    it { is_expected.to contain_file("expires.conf").with_content(
        "ExpiresActive On\n" \
        "ExpiresByType text/json \"mod plus 1 day\"\n" \
        "ExpiresByType text/html \"access plus 1 year\"\n"
      )
    }
  end
end
