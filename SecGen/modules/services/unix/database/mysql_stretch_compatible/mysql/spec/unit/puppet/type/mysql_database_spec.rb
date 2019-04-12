require 'puppet'
require 'puppet/type/mysql_database'
describe Puppet::Type.type(:mysql_database) do
  let(:user) { Puppet::Type.type(:mysql_database).new(name: 'test', charset: 'utf8', collate: 'utf8_blah_ci') }

  it 'accepts a database name' do
    expect(user[:name]).to eq('test')
  end

  it 'accepts a charset' do
    user[:charset] = 'latin1'
    expect(user[:charset]).to eq('latin1')
  end

  it 'accepts a collate' do
    user[:collate] = 'latin1_swedish_ci'
    expect(user[:collate]).to eq('latin1_swedish_ci')
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:mysql_database).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end
end
