require 'spec_helper'

describe "Facter::Util::Fact iptables_persistent_version" do


  context "iptables-persistent applicable" do
    before { Facter.clear }

    let(:dpkg_cmd) { "dpkg-query -Wf '${Version}' iptables-persistent 2>/dev/null" }

    {
      "Debian" => "0.0.20090701",
      "Ubuntu" => "0.5.3ubuntu2",
    }.each do |os, ver|

      if os == "Debian"
        os_release = "7.0"
      elsif os == "Ubuntu"
        os_release = "14.04"
      end

      describe "#{os} package installed" do
        before {
          allow(Facter.fact(:operatingsystem)).to receive(:value).and_return(os)
          allow(Facter.fact(:operatingsystemrelease)).to receive(:value).and_return(os_release)
          allow(Facter::Util::Resolution).to receive(:exec).with(dpkg_cmd).
            and_return(ver)
        }
        it { Facter.fact(:iptables_persistent_version).value.should == ver }
      end
    end

    describe 'Ubuntu package not installed' do
      before {
        allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('Ubuntu')
        allow(Facter.fact(:operatingsystemrelease)).to receive(:value).and_return('14.04')
        allow(Facter::Util::Resolution).to receive(:exec).with(dpkg_cmd).
          and_return(nil)
      }
      it { Facter.fact(:iptables_persistent_version).value.should be_nil }
    end

    describe 'CentOS not supported' do
      before { allow(Facter.fact(:operatingsystem)).to receive(:value).
                 and_return("CentOS") }
      it { Facter.fact(:iptables_persistent_version).value.should be_nil }
    end

  end

  context "netfilter-persistent applicable" do
    before { Facter.clear }

    let(:dpkg_cmd) { "dpkg-query -Wf '${Version}' netfilter-persistent 2>/dev/null" }

    {
      "Debian" => "0.0.20090701",
      "Ubuntu" => "0.5.3ubuntu2",
    }.each do |os, ver|

      if os == "Debian"
        os_release = "8.0"
      elsif os == "Ubuntu"
        os_release = "14.10"
      end

      describe "#{os} package installed" do
        before {
          allow(Facter.fact(:operatingsystem)).to receive(:value).and_return(os)
          allow(Facter.fact(:operatingsystemrelease)).to receive(:value).and_return(os_release)
          allow(Facter::Util::Resolution).to receive(:exec).with(dpkg_cmd).
            and_return(ver)
        }
        it { Facter.fact(:iptables_persistent_version).value.should == ver }
      end
    end

    describe 'Ubuntu package not installed' do
      os_release = "14.10"
      before {
        allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('Ubuntu')
        allow(Facter.fact(:operatingsystemrelease)).to receive(:value).and_return(os_release)
        allow(Facter::Util::Resolution).to receive(:exec).with(dpkg_cmd).
          and_return(nil)
      }
      it { Facter.fact(:iptables_persistent_version).value.should be_nil }
    end

    describe 'CentOS not supported' do
      before { allow(Facter.fact(:operatingsystem)).to receive(:value).
                 and_return("CentOS") }
      it { Facter.fact(:iptables_persistent_version).value.should be_nil }
    end

  end




end
