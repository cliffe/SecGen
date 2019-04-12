require 'spec_helper'

describe 'java_libjvm_path' do
  before(:each) do
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns('Linux')
    java_default_home = '/usr/lib/jvm/java-8-openjdk-amd64'
    Facter.fact(:java_default_home).stubs(:value).returns(java_default_home)
    Dir.stubs(:glob).with("#{java_default_home}/jre/lib/**/libjvm.so").returns(['/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/libjvm.so'])
  end

  context 'when on Linux, return libjvm path' do
    it do
      expect(Facter.value(:java_libjvm_path)).to eql '/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server'
    end
  end
end
