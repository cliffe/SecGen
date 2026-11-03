require 'puppet'
require 'puppet/type/mysql_user'
require 'spec_helper'
describe Puppet::Type.type(:mysql_user) do
  context 'On MySQL 5.x' do
    before :each do
      Facter.stubs(:value).with(:mysql_version).returns('5.6.24')
    end

    it 'fails with a long user name' do
      expect {
        Puppet::Type.type(:mysql_user).new(name: '12345678901234567@localhost', password_hash: 'pass')
      }.to raise_error %r{MySQL usernames are limited to a maximum of 16 characters}
    end
  end

  context 'On MariaDB 10.0.0+' do
    let(:user) { Puppet::Type.type(:mysql_user).new(name: '12345678901234567@localhost', password_hash: 'pass') }

    before :each do
      Facter.stubs(:value).with(:mysql_version).returns('10.0.19')
    end

    it 'succeeds with a long user name on MariaDB' do
      expect(user[:name]).to eq('12345678901234567@localhost')
    end
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:mysql_user).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  context 'using foo@localhost' do
    let(:user) { Puppet::Type.type(:mysql_user).new(name: 'foo@localhost', password_hash: 'pass') }

    it 'accepts a user name' do
      expect(user[:name]).to eq('foo@localhost')
    end

    it 'accepts a password' do
      user[:password_hash] = 'foo'
      expect(user[:password_hash]).to eq('foo')
    end

    it 'accepts an empty password' do
      user[:password_hash] = ''
      expect(user[:password_hash]).to eq('')
    end
  end

  context 'using foo@LocalHost' do
    let(:user) { Puppet::Type.type(:mysql_user).new(name: 'foo@LocalHost', password_hash: 'pass') }

    it 'lowercases the user name' do
      expect(user[:name]).to eq('foo@localhost')
    end
  end

  context 'using foo@192.168.1.0/255.255.255.0' do
    let(:user) { Puppet::Type.type(:mysql_user).new(name: 'foo@192.168.1.0/255.255.255.0', password_hash: 'pass') }

    it 'creates the user with the netmask' do
      expect(user[:name]).to eq('foo@192.168.1.0/255.255.255.0')
    end
  end

  context 'using allo_wed$char@localhost' do
    let(:user) { Puppet::Type.type(:mysql_user).new(name: 'allo_wed$char@localhost', password_hash: 'pass') }

    it 'accepts a user name' do
      expect(user[:name]).to eq('allo_wed$char@localhost')
    end
  end

  context 'ensure the default \'debian-sys-main\'@localhost user can be parsed' do
    let(:user) { Puppet::Type.type(:mysql_user).new(name: '\'debian-sys-maint\'@localhost', password_hash: 'pass') }

    it 'accepts a user name' do
      expect(user[:name]).to eq('\'debian-sys-maint\'@localhost')
    end
  end

  context 'using a quoted 16 char username' do
    let(:user) { Puppet::Type.type(:mysql_user).new(name: '"debian-sys-maint"@localhost', password_hash: 'pass') }

    it 'accepts a user name' do
      expect(user[:name]).to eq('"debian-sys-maint"@localhost')
    end
  end

  context 'using a quoted username that is too long ' do
    before :each do
      Facter.stubs(:value).with(:mysql_version).returns('5.6.24')
    end

    it 'fails with a size error' do
      expect {
        Puppet::Type.type(:mysql_user).new(name: '"debian-sys-maint2"@localhost', password_hash: 'pass')
      }.to raise_error %r{MySQL usernames are limited to a maximum of 16 characters}
    end
  end

  context 'using `speci!al#`@localhost' do
    let(:user) { Puppet::Type.type(:mysql_user).new(name: '`speci!al#`@localhost', password_hash: 'pass') }

    it 'accepts a quoted user name with special chatracters' do
      expect(user[:name]).to eq('`speci!al#`@localhost')
    end
  end

  context 'using in-valid@localhost' do
    let(:user) { Puppet::Type.type(:mysql_user).new(name: 'in-valid@localhost', password_hash: 'pass') }

    it 'accepts a user name with special chatracters' do
      expect(user[:name]).to eq('in-valid@localhost')
    end
  end

  context 'using "misquoted@localhost' do
    it 'fails with a misquoted username is used' do
      expect {
        Puppet::Type.type(:mysql_user).new(name: '"misquoted@localhost', password_hash: 'pass')
      }.to raise_error %r{Invalid database user "misquoted@localhost}
    end
  end
end
