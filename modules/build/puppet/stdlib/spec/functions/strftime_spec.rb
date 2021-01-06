require 'spec_helper'

describe 'strftime' do
  it 'exists' do
    expect(Puppet::Parser::Functions.function('strftime')).to eq('function_strftime')
  end

  it 'raises a ParseError if there is less than 1 arguments' do
    expect { scope.function_strftime([]) }.to(raise_error(Puppet::ParseError))
  end

  it 'using %s should be higher then when I wrote this test' do
    result = scope.function_strftime(['%s'])
    expect(result.to_i).to(be > 1_311_953_157)
  end

  it 'using %s should be greater than 1.5 trillion' do
    result = scope.function_strftime(['%s'])
    expect(result.to_i).to(be > 1_500_000_000)
  end

  it 'returns a date when given %Y-%m-%d' do
    result = scope.function_strftime(['%Y-%m-%d'])
    expect(result).to match(%r{^\d{4}-\d{2}-\d{2}$})
  end
end
