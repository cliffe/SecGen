require 'spec_helper'

describe 'dig' do
  it 'exists' do
    expect(Puppet::Parser::Functions.function('dig')).to eq('function_dig')
  end

  it 'gives a deprecation warning when called' do
    scope.expects(:warning).with('dig() DEPRECATED: This function has been replaced in Puppet 4.5.0, please use dig44() for backwards compatibility or use the new version.')
    scope.function_dig([{}, []])
  end
end
