require 'spec_helper'

describe 'has_interface_with' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params("one", "two", "three").and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }

  # We need to mock out the Facts so we can specify how we expect this function
  # to behave on different platforms.
  context "On Mac OS X Systems" do
    let(:facts) { { :interfaces => 'lo0,gif0,stf0,en1,p2p0,fw0,en0,vmnet1,vmnet8,utun0' } }
    it { is_expected.to run.with_params('lo0').and_return(true) }
    it { is_expected.to run.with_params('lo').and_return(false) }
  end

  context "On Linux Systems" do
    let(:facts) do
      {
        :interfaces => 'eth0,lo',
        :ipaddress => '10.0.0.1',
        :ipaddress_lo => '127.0.0.1',
        :ipaddress_eth0 => '10.0.0.1',
        :muppet => 'kermit',
        :muppet_lo => 'mspiggy',
        :muppet_eth0 => 'kermit',
      }
    end

    it { is_expected.to run.with_params('lo').and_return(true) }
    it { is_expected.to run.with_params('lo0').and_return(false) }
    it { is_expected.to run.with_params('ipaddress', '127.0.0.1').and_return(true) }
    it { is_expected.to run.with_params('ipaddress', '10.0.0.1').and_return(true) }
    it { is_expected.to run.with_params('ipaddress', '8.8.8.8').and_return(false) }
    it { is_expected.to run.with_params('muppet', 'kermit').and_return(true) }
    it { is_expected.to run.with_params('muppet', 'mspiggy').and_return(true) }
    it { is_expected.to run.with_params('muppet', 'bigbird').and_return(false) }
  end
end
