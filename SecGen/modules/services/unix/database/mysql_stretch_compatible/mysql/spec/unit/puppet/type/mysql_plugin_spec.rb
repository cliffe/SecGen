require 'puppet'
require 'puppet/type/mysql_plugin'
describe Puppet::Type.type(:mysql_plugin) do
  let(:plugin) { Puppet::Type.type(:mysql_plugin).new(name: 'test', soname: 'test.so') }

  it 'accepts a plugin name' do
    expect(plugin[:name]).to eq('test')
  end

  it 'accepts a library name' do
    plugin[:soname] = 'test.so'
    expect(plugin[:soname]).to eq('test.so')
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:mysql_plugin).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end
end
