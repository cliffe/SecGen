require 'spec_helper'

describe 'union' do
  describe 'argument checking' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it { is_expected.to run.with_params('one', []).and_raise_error(Puppet::ParseError, %r{Every parameter must be an array}) }
    it { is_expected.to run.with_params([], 'two').and_raise_error(Puppet::ParseError, %r{Every parameter must be an array}) }
    it { is_expected.to run.with_params({}, {}).and_raise_error(Puppet::ParseError, %r{Every parameter must be an array}) }
  end

  it { is_expected.to run.with_params([], []).and_return([]) }
  it { is_expected.to run.with_params([], ['one']).and_return(['one']) }
  it { is_expected.to run.with_params(['one'], []).and_return(['one']) }
  it { is_expected.to run.with_params(['one'], ['one']).and_return(['one']) }
  it { is_expected.to run.with_params(['one'], ['two']).and_return(%w[one two]) }
  it { is_expected.to run.with_params(%w[one two three], %w[two three]).and_return(%w[one two three]) }
  it { is_expected.to run.with_params(%w[one two two three], %w[two three]).and_return(%w[one two three]) }
  it { is_expected.to run.with_params(%w[one two three], %w[two two three]).and_return(%w[one two three]) }
  it { is_expected.to run.with_params(%w[one two], %w[two three], %w[one three]).and_return(%w[one two three]) }
  it { is_expected.to run.with_params(%w[one two], %w[three four], %w[one two three], ['four']).and_return(%w[one two three four]) }
  it { is_expected.to run.with_params(%w[ốńə ţשׂợ], %w[ŧĥяếệ ƒởųŗ], %w[ốńə ţשׂợ ŧĥяếệ], ['ƒởųŗ']).and_return(%w[ốńə ţשׂợ ŧĥяếệ ƒởųŗ]) }
  it 'does not confuse types' do is_expected.to run.with_params(%w[1 2 3], [1, 2]).and_return(['1', '2', '3', 1, 2]) end
end
