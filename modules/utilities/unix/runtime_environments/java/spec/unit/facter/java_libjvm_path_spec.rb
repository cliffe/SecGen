require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns('Linux')
    java_default_home = '/usr/lib/jvm/java-8-openjdk-amd64'
    Facter.fact(:java_default_home).stubs(:value).returns(java_default_home)
    Dir.stubs(:glob).with("#{java_default_home}/jre/lib/**/libjvm.so").returns( ['/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/libjvm.so'])
  }

  describe "java_libjvm_path" do
    context 'returns libjvm path' do
      context 'on Linux' do
        it do
          Facter.value(:java_libjvm_path).should == "/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server"
        end
      end
    end
  end
end
