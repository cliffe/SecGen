require 'spec_helper'

# Helper function for testing the contents of `proxy_balancer.conf`
def balancer_manager_conf_spec(allow_from, manager_path)
  it do
    is_expected.to contain_file("proxy_balancer.conf").with_content(
      "<Location #{manager_path}>\n"\
      "    SetHandler balancer-manager\n"\
      "    Require ip #{Array(allow_from).join(' ')}\n"\
      "</Location>\n"
    )
  end
end

describe 'apache::mod::proxy_balancer', :type => :class do
  let :pre_condition do
    [
      'include apache::mod::proxy',
    ]
  end
  it_behaves_like "a mod class, without including apache"

  context "default configuration with default parameters" do
    context "on a Debian OS" do
      let :facts do
        {
          :osfamily               => 'Debian',
          :operatingsystemrelease => '8',
          :concat_basedir         => '/dne',
          :lsbdistcodename        => 'jessie',
          :operatingsystem        => 'Debian',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end

      it { is_expected.to contain_apache__mod("proxy_balancer") }

      it { is_expected.to_not contain_file("proxy_balancer.conf") }
      it { is_expected.to_not contain_file("proxy_balancer.conf symlink") }

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
          :is_pe                  => false,
        }
      end

      it { is_expected.to contain_apache__mod("proxy_balancer") }

      it { is_expected.to_not contain_file("proxy_balancer.conf") }
      it { is_expected.to_not contain_file("proxy_balancer.conf symlink") }

    end
  end

  context "default configuration with custom parameters $manager => true, $allow_from => ['10.10.10.10','11.11.11.11'], $status_path => '/custom-manager'" do
    context "on a Debian OS" do
      let :facts do
        {
          :osfamily               => 'Debian',
          :operatingsystemrelease => '8',
          :concat_basedir         => '/dne',
          :lsbdistcodename        => 'jessie',
          :operatingsystem        => 'Debian',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do
        {
          :manager      => true,
          :allow_from   => ['10.10.10.10','11.11.11.11'],
          :manager_path => '/custom-manager',
        }
      end

      balancer_manager_conf_spec(["10.10.10.10", "11.11.11.11"], "/custom-manager")

    end
  end
end
