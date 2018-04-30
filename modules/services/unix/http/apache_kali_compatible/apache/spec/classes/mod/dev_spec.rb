require 'spec_helper'

describe 'apache::mod::dev', :type => :class do
  let(:pre_condition) {[
    'include apache'
  ]}

  it_behaves_like "a mod class, without including apache"

  [
    ['RedHat',  '6', 'Santiago', 'Linux'],
    ['Debian',  '6', 'squeeze', 'Linux'],
    ['FreeBSD', '9', 'FreeBSD', 'FreeBSD'],
  ].each do |osfamily, operatingsystemrelease, lsbdistcodename, kernel|
    context "on a #{osfamily} OS" do
      let :facts do
        {
          :lsbdistcodename        => lsbdistcodename,
          :osfamily               => osfamily,
          :operatingsystem        => osfamily,
          :operatingsystemrelease => operatingsystemrelease,
          :is_pe                  => false,
          :concat_basedir         => '/foo',
          :id                     => 'root',
          :path                   => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
          :kernel                 => kernel
        }
      end
      it { is_expected.to contain_class('apache::dev') }
    end
  end
end
