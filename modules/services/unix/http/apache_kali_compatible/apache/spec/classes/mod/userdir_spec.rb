require 'spec_helper'

describe 'apache::mod::userdir', :type => :class do
  context "on a Debian OS" do
    let :pre_condition do
      'class { "apache":
         default_mods => false,
         mod_dir      => "/tmp/junk",
       }'
    end
    let :facts do
      {
        :lsbdistcodename           => 'squeeze',
        :osfamily                  => 'Debian',
        :operatingsystemrelease    => '6',
        :operatingsystemmajrelease => '6',
        :concat_basedir            => '/dne',
        :operatingsystem           => 'Debian',
        :id                        => 'root',
        :kernel                    => 'Linux',
        :path                      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    context "default parameters" do
      it { should compile }
    end
    context "with dir set to something" do
      let :params do
        {
          :dir => 'hi',
        }
      end
      it { should contain_file("userdir.conf").with_content(%r{^\s*UserDir\s+/home/\*/hi$})}
    end
    context "with home set to something" do
      let :params do
        {
          :home => '/u',
        }
      end
      it { should contain_file("userdir.conf").with_content(%r{^\s*UserDir\s+/u/\*/public_html$})}
    end
    context "with path set to something" do
      let :params do
        {
          :path => 'public_html /usr/web http://www.example.com/',
        }
      end
      it { should contain_file("userdir.conf").with_content(%r{^\s*UserDir\s+public_html /usr/web http://www\.example\.com/$})}
    end
  end
end
