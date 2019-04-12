require 'spec_helper'

describe 'wordpress::instance', :type => :define do
  let :title do
    '/opt/wordpress2'
  end
  let :params do
    {
      :db_user => 'test',
      :db_name => 'test'
    }
  end
  context "on a RedHat 5 OS" do
    let :facts do
      {
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '5',
        :concat_basedir    => '/dne',
      }
    end
    it { should contain_wordpress__instance__app("/opt/wordpress2") }
    it { should contain_wordpress__instance__db("localhost/test") }
  end
  context "on a RedHat 6 OS" do
    let :facts do
      {
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
        :concat_basedir    => '/dne',
      }
    end
    it { should contain_wordpress__instance__app("/opt/wordpress2") }
    it { should contain_wordpress__instance__db("localhost/test") }
  end
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily       => 'Debian',
        :concat_basedir => '/dne',
      }
    end
    it { should contain_wordpress__instance__app("/opt/wordpress2") }
    it { should contain_wordpress__instance__db("localhost/test") }
  end
end
