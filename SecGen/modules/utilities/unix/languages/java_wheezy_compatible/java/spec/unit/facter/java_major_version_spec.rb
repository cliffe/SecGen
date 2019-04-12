require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe "java_major_version" do
    context 'returns major version when java_version fact present' do
      before :each do
        Facter.fact(:java_version).stubs(:value).returns('1.7.0_71')
      end
      it do
        expect(Facter.fact(:java_major_version).value).to eq("7")
      end
    end

    context 'returns nil when java not present' do
      before :each do
        Facter.fact(:java_version).stubs(:value).returns(nil)
      end
      it do
        expect(Facter.fact(:java_major_version).value).to be_nil
      end
    end
  end
end
