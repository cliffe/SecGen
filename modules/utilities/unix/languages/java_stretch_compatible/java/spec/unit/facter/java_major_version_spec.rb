require 'spec_helper'

describe 'java_major_version' do
  before(:each) do
    Facter.clear
  end

  context 'when java_version fact present, returns major version' do
    before :each do
      Facter.fact(:java_version).stubs(:value).returns('1.7.0_71')
    end
    it do
      expect(Facter.fact(:java_major_version).value).to eq('7')
    end
  end

  context 'when java not present, returns nil' do
    before :each do
      Facter.fact(:java_version).stubs(:value).returns(nil)
    end
    it do
      expect(Facter.fact(:java_major_version).value).to be_nil
    end
  end
end
