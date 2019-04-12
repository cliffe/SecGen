require 'spec_helper'

describe 'union' do
  describe 'argument checking' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
    it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
    it { is_expected.to run.with_params('one', []).and_raise_error(Puppet::ParseError, /Every parameter must be an array/) }
    it { is_expected.to run.with_params([], 'two').and_raise_error(Puppet::ParseError, /Every parameter must be an array/) }
    it { is_expected.to run.with_params({}, {}).and_raise_error(Puppet::ParseError, /Every parameter must be an array/) }
  end

  it { is_expected.to run.with_params([], []).and_return([]) }
  it { is_expected.to run.with_params([], ['one']).and_return(['one']) }
  it { is_expected.to run.with_params(['one'], []).and_return(['one']) }
  it { is_expected.to run.with_params(['one'], ['one']).and_return(['one']) }
  it { is_expected.to run.with_params(['one'], ['two']).and_return(['one', 'two']) }
  it { is_expected.to run.with_params(['one', 'two', 'three'], ['two', 'three']).and_return(['one', 'two', 'three']) }
  it { is_expected.to run.with_params(['one', 'two', 'two', 'three'], ['two', 'three']).and_return(['one', 'two', 'three']) }
  it { is_expected.to run.with_params(['one', 'two', 'three'], ['two', 'two', 'three']).and_return(['one', 'two', 'three']) }
  it { is_expected.to run.with_params(['one', 'two'], ['two', 'three'], ['one', 'three']).and_return(['one', 'two', 'three']) }
  it { is_expected.to run.with_params(['one', 'two'], ['three', 'four'], ['one', 'two', 'three'], ['four']).and_return(['one', 'two', 'three', 'four']) }
  it { is_expected.to run.with_params(['ốńə', 'ţשׂợ'], ['ŧĥяếệ', 'ƒởųŗ'], ['ốńə', 'ţשׂợ', 'ŧĥяếệ'], ['ƒởųŗ']).and_return(['ốńə', 'ţשׂợ', 'ŧĥяếệ', 'ƒởųŗ']) }
  it 'should not confuse types' do is_expected.to run.with_params(['1', '2', '3'], [1, 2]).and_return(['1', '2', '3', 1, 2]) end
end
