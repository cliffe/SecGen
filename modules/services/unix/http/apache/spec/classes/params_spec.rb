require 'spec_helper'

describe 'apache::params', :type => :class do
  context "On a Debian OS" do
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

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_resource_count(0) }
  end
end
