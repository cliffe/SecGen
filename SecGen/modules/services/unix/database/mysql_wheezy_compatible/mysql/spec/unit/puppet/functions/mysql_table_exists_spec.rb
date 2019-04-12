require 'spec_helper'

describe 'the mysql_table_exists function' do
  before :all do
    Puppet::Parser::Functions.autoloader.loadall
  end

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    expect(Puppet::Parser::Functions.function('mysql_table_exists')).to eq('function_mysql_table_exists')
  end

  it 'should raise a ParseError if there is less than 1 arguments' do
    expect { scope.function_mysql_table_exists([]) }.to( raise_error(Puppet::ParseError))
  end

  it 'should raise a ParserError if argument doesn\'t look like database_name.table_name' do
    expect { scope.function_mysql_table_exists(['foo_bar']) }.to( raise_error(Puppet::ParseError))
  end

  it 'should raise a ParseError if there is more than 1 arguments' do
    expect { scope.function_mysql_table_exists(%w(foo.bar foo.bar)) }.to( raise_error(Puppet::ParseError))
  end

end