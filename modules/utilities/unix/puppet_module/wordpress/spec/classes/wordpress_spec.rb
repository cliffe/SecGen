require 'spec_helper'

describe 'wordpress', :type => :class do
  context "on a RedHat 5 OS" do
    let :facts do
      {
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '5',
        :concat_basedir    => '/dne',
      }
    end
    it { should contain_wordpress__instance__app("/opt/wordpress") }
    it { should contain_wordpress__instance__db("localhost/wordpress") }
  end
  context "on a RedHat 6 OS" do
    let :facts do
      {
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
        :concat_basedir    => '/dne',
      }
    end
    it { should contain_wordpress__instance__app("/opt/wordpress") }
    it { should contain_wordpress__instance__db("localhost/wordpress") }
  end
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily       => 'Debian',
        :concat_basedir => '/dne',
      }
    end
    it { should contain_wordpress__instance__app("/opt/wordpress") }
    it { should contain_wordpress__instance__db("localhost/wordpress") }
  end
end
