require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe "mysql_server_id" do
    context "igalic's laptop" do
      before :each do
        Facter.fact(:macaddress).stubs(:value).returns('3c:97:0e:69:fb:e1')
      end
      it do
        Facter.fact(:mysql_server_id).value.to_s.should == '66961985441'
      end
    end

    context "node with lo only" do
      before :each do
        Facter.fact(:macaddress).stubs(:value).returns('00:00:00:00:00:00')
      end
      it do
        Facter.fact(:mysql_server_id).value.to_s.should == '0'
      end
    end
  end
end
