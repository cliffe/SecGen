require 'spec_helper'

describe 'the mysql_password function' do
  before :all do # rubocop:disable RSpec/BeforeAfterAll
    Puppet::Parser::Functions.autoloader.loadall
  end

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'exists' do
    expect(Puppet::Parser::Functions.function('mysql_password')).to eq('function_mysql_password')
  end

  it 'raises a ParseError if there is less than 1 arguments' do
    expect { scope.function_mysql_password([]) }.to(raise_error(Puppet::ParseError))
  end

  it 'raises a ParseError if there is more than 1 arguments' do
    expect { scope.function_mysql_password(['foo', 'bar']) }.to(raise_error(Puppet::ParseError))
  end

  it 'converts password into a hash' do
    result = scope.function_mysql_password(['password'])
    expect(result).to(eq('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19'))
  end

  it 'converts an empty password into a empty string' do
    result = scope.function_mysql_password([''])
    expect(result).to(eq(''))
  end

  it 'does not convert a password that is already a hash' do
    result = scope.function_mysql_password(['*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19'])
    expect(result).to(eq('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19'))
  end
end
