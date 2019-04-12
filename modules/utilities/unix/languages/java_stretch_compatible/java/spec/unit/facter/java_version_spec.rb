require 'spec_helper'

openjdk_7_output = "Picked up JAVA_TOOL_OPTIONS: -Djava.net.preferIPv4Stack=true\n"\
                   "openjdk version \"1.7.0_71\"\n"\
                   "OpenJDK Runtime Environment (build 1.7.0_71-b14)\n"\
                   "OpenJDK 64-Bit Server VM (build 24.71-b01, mixed mode)\n"

jdk_7_hotspot_output = "Picked up JAVA_TOOL_OPTIONS: -Djava.net.preferIPv4Stack=true\n"\
                       "java version \"1.7.0_71\"\n"\
                       "Java(TM) SE Runtime Environment (build 1.7.0_71-b14)\n"\
                       "Java HotSpot(TM) 64-Bit Server VM (build 24.71-b01, mixed mode)\n"

describe 'java_version' do
  before(:each) do
    Facter.clear
  end

  context 'when java present, returns java version' do
    context 'on OpenBSD', with_env: true do
      before(:each) do
        Facter.fact(:operatingsystem).stubs(:value).returns('OpenBSD')
      end
      let(:facts) { { operatingsystem: 'OpenBSD' } }

      it do
        Facter::Util::Resolution.expects(:which).with('java').returns('/usr/local/jdk-1.7.0/jre/bin/java')
        Facter::Util::Resolution.expects(:exec).with('java -Xmx12m -version 2>&1').returns(openjdk_7_output)
        expect(Facter.value(:java_version)).to eq('1.7.0_71')
      end
    end
    context 'when on Darwin' do
      before(:each) do
        Facter.fact(:operatingsystem).stubs(:value).returns('Darwin')
      end
      let(:facts) { { operatingsystem: 'Darwin' } }

      it do
        Facter::Util::Resolution.expects(:exec).with('/usr/libexec/java_home --failfast 2>&1').returns('/Library/Java/JavaVirtualMachines/jdk1.7.0_71.jdk/Contents/Home')
        Facter::Util::Resolution.expects(:exec).with('java -Xmx12m -version 2>&1').returns(jdk_7_hotspot_output)
        expect(Facter.value(:java_version)).to eql '1.7.0_71'
      end
    end
    context 'when on other systems' do
      before(:each) do
        Facter.fact(:operatingsystem).stubs(:value).returns('MyOS')
      end
      let(:facts) { { operatingsystem: 'MyOS' } }

      it do
        Facter::Util::Resolution.expects(:which).with('java').returns('/path/to/java')
        Facter::Util::Resolution.expects(:exec).with('java -Xmx12m -version 2>&1').returns(jdk_7_hotspot_output)
        expect(Facter.value(:java_version)).to eq('1.7.0_71')
      end
    end
  end

  context 'when java not present, returns nil' do
    context 'on OpenBSD', with_env: true do
      before(:each) do
        Facter.fact(:operatingsystem).stubs(:value).returns('OpenBSD')
      end
      let(:facts) { { operatingsystem: 'OpenBSD' } }

      it do
        Facter::Util::Resolution.stubs(:exec)
        expect(Facter.value(:java_version)).to be_nil
      end
    end
    context 'when on Darwin' do
      before(:each) do
        Facter.fact(:operatingsystem).stubs(:value).returns('Darwin')
      end
      let(:facts) { { operatingsystem: 'Darwin' } }

      it do
        Facter::Util::Resolution.expects(:exec).at_least(1).with('/usr/libexec/java_home --failfast 2>&1').returns('Unable to find any JVMs matching version "(null)".')
        expect(Facter.value(:java_version)).to be_nil
      end
    end
    context 'when on other systems' do
      before(:each) do
        Facter.fact(:operatingsystem).stubs(:value).returns('MyOS')
      end
      let(:facts) { { operatingsystem: 'MyOS' } }

      it do
        Facter::Util::Resolution.expects(:which).at_least(1).with('java').returns(false)
        expect(Facter.value(:java_version)).to be_nil
      end
    end
  end
end
