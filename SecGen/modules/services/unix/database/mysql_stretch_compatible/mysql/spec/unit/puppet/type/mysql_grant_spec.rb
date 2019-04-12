require 'puppet'
require 'puppet/type/mysql_grant'
require 'spec_helper'
describe Puppet::Type.type(:mysql_grant) do
  let(:user) { Puppet::Type.type(:mysql_grant).new(name: 'foo@localhost/*.*', privileges: ['ALL'], table: ['*.*'], user: 'foo@localhost') }

  it 'accepts a grant name' do
    expect(user[:name]).to eq('foo@localhost/*.*')
  end

  it 'accepts ALL privileges' do
    user[:privileges] = 'ALL'
    expect(user[:privileges]).to eq(['ALL'])
  end

  context 'PROXY privilege with mysql greater than or equal to 5.5.0' do
    before :each do
      Facter.stubs(:value).with(:mysql_version).returns('5.5.0')
    end

    it 'does not raise error' do
      user[:privileges] = 'PROXY'
      user[:table]      = 'proxy_user@proxy_host'
      expect(user[:privileges]).to eq(['PROXY'])
    end
  end

  context 'PROXY privilege with mysql greater than or equal to 5.4.0' do
    before :each do
      Facter.stubs(:value).with(:mysql_version).returns('5.4.0')
    end

    it 'raises error' do
      expect {
        user[:privileges] = 'PROXY'
      }.to raise_error(Puppet::ResourceError, %r{PROXY user not supported on mysql versions < 5.5.0})
    end
  end

  it 'accepts a table' do
    user[:table] = '*.*'
    expect(user[:table]).to eq('*.*')
  end

  it 'accepts @ for table' do
    user[:table] = '@'
    expect(user[:table]).to eq('@')
  end

  it 'accepts proxy user for table' do
    user[:table] = 'proxy_user@proxy_host'
    expect(user[:table]).to eq('proxy_user@proxy_host')
  end

  it 'accepts a user' do
    user[:user] = 'foo@localhost'
    expect(user[:user]).to eq('foo@localhost')
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:mysql_grant).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'requires the name to match the user and table #general' do
    expect {
      Puppet::Type.type(:mysql_grant).new(name: 'foo@localhost/*.*', privileges: ['ALL'], table: ['*.*'], user: 'foo@localhost')
    }.not_to raise_error
  end
  it 'requires the name to match the user and table #specific' do
    expect {
      Puppet::Type.type(:mysql_grant).new(name: 'foo', privileges: ['ALL'], table: ['*.*'], user: 'foo@localhost')
    }.to raise_error %r{`name` `parameter` must match user@host\/table format}
  end

  describe 'it should munge privileges' do
    it 'to just ALL' do
      user = Puppet::Type.type(:mysql_grant).new(
        name: 'foo@localhost/*.*', table: ['*.*'], user: 'foo@localhost',
        privileges: ['ALL']
      )
      expect(user[:privileges]).to eq(['ALL'])
    end

    it 'to upcase and ordered' do
      user = Puppet::Type.type(:mysql_grant).new(
        name: 'foo@localhost/*.*', table: ['*.*'], user: 'foo@localhost',
        privileges: ['select', 'Insert']
      )
      expect(user[:privileges]).to eq(['INSERT', 'SELECT'])
    end

    it 'ordered including column privileges' do
      user = Puppet::Type.type(:mysql_grant).new(
        name: 'foo@localhost/*.*', table: ['*.*'], user: 'foo@localhost',
        privileges: ['SELECT(Host,Address)', 'Insert']
      )
      expect(user[:privileges]).to eq(['INSERT', 'SELECT (Address, Host)'])
    end
  end
end
