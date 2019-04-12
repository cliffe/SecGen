require 'spec_helper'

describe Facter::Util::Fact.to_s do
  before(:each) do
    Facter.clear
  end

  describe 'mysqld_version' do
    context 'with value' do
      before :each do
        Facter::Util::Resolution.stubs(:exec).with('mysqld --no-defaults -V 2>/dev/null').returns('mysqld  Ver 5.5.49-37.9 for Linux on x86_64 (Percona Server (GPL), Release 37.9, Revision efa0073)')
      end
      it {
        expect(Facter.fact(:mysqld_version).value).to eq('mysqld  Ver 5.5.49-37.9 for Linux on x86_64 (Percona Server (GPL), Release 37.9, Revision efa0073)')
      }
    end
  end
end
