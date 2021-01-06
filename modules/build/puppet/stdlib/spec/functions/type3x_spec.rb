require 'spec_helper'

describe 'type3x' do
  it 'exists' do
    expect(Puppet::Parser::Functions.function('type3x')).to eq('function_type3x')
  end

  it 'raises a ParseError if there is less than 1 arguments' do
    expect { scope.function_type3x([]) }.to(raise_error(Puppet::ParseError))
  end

  it 'returns string when given a string' do
    result = scope.function_type3x(['aaabbbbcccc'])
    expect(result).to(eq('string'))
  end

  it 'returns array when given an array' do
    result = scope.function_type3x([%w[aaabbbbcccc asdf]])
    expect(result).to(eq('array'))
  end

  it 'returns hash when given a hash' do
    result = scope.function_type3x([{ 'a' => 1, 'b' => 2 }])
    expect(result).to(eq('hash'))
  end

  it 'returns integer when given an integer' do
    result = scope.function_type3x(['1'])
    expect(result).to(eq('integer'))
  end

  it 'returns float when given a float' do
    result = scope.function_type3x(['1.34'])
    expect(result).to(eq('float'))
  end

  it 'returns boolean when given a boolean' do
    result = scope.function_type3x([true])
    expect(result).to(eq('boolean'))
  end
end
