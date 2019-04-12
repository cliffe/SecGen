require 'spec_helper'

describe 'filebeat_version' do
  before :each do
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns('Linux')
  end
  context 'when on a Linux host' do
    before :each do
      File.stubs(:executable?)
      Facter::Util::Resolution.stubs(:exec)
      File.expects(:executable?).with('/usr/share/filebeat/bin/filebeat').returns true
      Facter::Util::Resolution.stubs(:exec).with('/usr/share/filebeat/bin/filebeat --version').returns('filebeat version 5.1.1 (amd64), libbeat 5.1.1')
    end
    it 'returns the correct version' do
      expect(Facter.fact(:filebeat_version).value).to eq('5.1.1')
    end
  end

  context 'when the filebeat package is not installed' do
    before :each do
      File.stubs(:executable?)
      Facter::Util::Resolution.stubs(:exec)
      File.expects(:executable?).with('/usr/bin/filebeat').returns false
      File.expects(:executable?).with('/usr/local/bin/filebeat').returns false
      File.expects(:executable?).with('/usr/share/filebeat/bin/filebeat').returns false
      File.expects(:executable?).with('/usr/local/sbin/filebeat').returns false
      File.stubs(:exist?)
      File.expects(:exist?).with('c:\Program Files\Filebeat\filebeat.exe').returns false
    end
    it 'returns false' do
      expect(Facter.fact(:filebeat_version).value).to eq(false)
    end
  end
end
