require 'spec_helper'

java_7_path = '/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java'
java_7_home = '/usr/lib/jvm/java-7-openjdk-amd64'
java_8_path = '/usr/lib/jvm/oracle-java8-jre-amd64/bin/java'
java_8_home = '/usr/lib/jvm/oracle-java8-jre-amd64'

def unlink_and_delete(filename)
  if File.symlink?(filename)
    File.unlink(filename)
  end
  return unless File.exist?(filename)
  File.delete(filename)
end

def symlink_and_test(symlink_path, java_home)
  File.symlink(symlink_path, './java_test')
  Facter::Util::Resolution.expects(:which).with('java').returns('./java_test')
  File.expects(:realpath).with('./java_test').returns(symlink_path)
  expect(Facter.value(:java_default_home)).to eql java_home
end

describe 'java_default_home' do
  before(:each) do
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns('Linux')
  end

  context 'when java found in PATH' do
    context 'when java is in /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java' do
      it do
        unlink_and_delete('./java_test')
        symlink_and_test(java_7_path, java_7_home)
        unlink_and_delete('./java_test')
      end
    end

    context 'when java is in /usr/lib/jvm/oracle-java8-jre-amd64/bin/java' do
      it do
        unlink_and_delete('./java_test')
        symlink_and_test(java_8_path, java_8_home)
        unlink_and_delete('./java_test')
      end
    end
  end

  context 'when java not present, return nil' do
    it do
      Facter::Util::Resolution.stubs(:exec)
      Facter::Util::Resolution.expects(:which).with('java').at_least(1).returns(false)
      expect(Facter.value(:java_default_home)).to be_nil
    end
  end
end
