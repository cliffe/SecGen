require 'spec_helper'

describe 'difference' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one', 'two').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one', 'two', 'three').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one', []).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params([], 'two').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params({}, {}).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params([], []).and_return([]) }
  it { is_expected.to run.with_params([], ['one']).and_return([]) }
  it { is_expected.to run.with_params(['one'], ['one']).and_return([]) }
  it { is_expected.to run.with_params(['ớņέ'], ['']).and_return(['ớņέ']) }
  it { is_expected.to run.with_params(['one'], []).and_return(['one']) }
  it { is_expected.to run.with_params(%w[one two three], %w[two three]).and_return(['one']) }
  it { is_expected.to run.with_params(['ớņέ', 'ŧשּׁō', 'ŧħґëə', 2], %w[ŧשּׁō ŧħґëə]).and_return(['ớņέ', 2]) }
  it { is_expected.to run.with_params(%w[one two two three], %w[two three]).and_return(['one']) }
  it { is_expected.to run.with_params(%w[one two three], %w[two two three]).and_return(['one']) }
  it { is_expected.to run.with_params(%w[one two three], %w[two three four]).and_return(['one']) }
  it 'does not confuse types' do is_expected.to run.with_params(%w[1 2 3], [1, 2]).and_return(%w[1 2 3]) end
end
