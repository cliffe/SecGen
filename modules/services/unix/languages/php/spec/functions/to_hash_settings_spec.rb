require 'spec_helper'

describe 'to_hash_settings' do
  input = { 'a' => 1, 'b' => 2 }
  results = [
    {
      'a' => { 'key' => 'a', 'value' => 1 },
      'b' => { 'key' => 'b', 'value' => 2 }
    },
    {
      'foo: a' => { 'key' => 'a', 'value' => 1 },
      'foo: b' => { 'key' => 'b', 'value' => 2 }
    }
  ]

  describe 'when first parameter is not a hash' do
    it { should run.with_params('baz', input).and_raise_error(Puppet::ParseError)}
  end

  describe 'when used with proper parameters' do
    it { should run.with_params(input).and_return(results[0]) }
    it { should run.with_params(input, 'foo').and_return(results[1]) }
  end
end
