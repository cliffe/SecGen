require 'spec_helper'
describe 'tomcat' do
  let :facts do
    {
      :osfamily => 'Debian'
    }
  end
  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('tomcat') }
  end
end
