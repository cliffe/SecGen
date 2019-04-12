require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe "nginx_version" do
    context 'with value' do
      before :each do
        Facter::Util::Resolution.stubs(:which).with('nginx').returns(true)
        Facter::Util::Resolution.stubs(:exec).with('nginx -v 2>&1').returns('nginx version: nginx/1.8.1')
      end
      it {
        expect(Facter.fact(:nginx_version).value).to eq('1.8.1')
      }
    end
  end
end
