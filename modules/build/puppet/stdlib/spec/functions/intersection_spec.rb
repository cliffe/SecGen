require 'spec_helper'

describe 'intersection' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one', 'two').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one', 'two', 'three').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one', []).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params([], 'two').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params({}, {}).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params([], []).and_return([]) }
  it { is_expected.to run.with_params([], ['one']).and_return([]) }
  it { is_expected.to run.with_params(['one'], []).and_return([]) }
  it { is_expected.to run.with_params(['one'], ['one']).and_return(['one']) }
  it { is_expected.to run.with_params(['one', 'two', 'three'], ['two', 'three']).and_return(['two', 'three']) }
  it { is_expected.to run.with_params(['ōŋể', 'ŧשợ', 'ţђŕẽё'], ['ŧשợ', 'ţђŕẽё']).and_return(['ŧשợ', 'ţђŕẽё']) }
  it { is_expected.to run.with_params(['one', 'two', 'two', 'three'], ['two', 'three']).and_return(['two', 'three']) }
  it { is_expected.to run.with_params(['one', 'two', 'three'], ['two', 'two', 'three']).and_return(['two', 'three']) }
  it { is_expected.to run.with_params(['one', 'two', 'three'], ['two', 'three', 'four']).and_return(['two', 'three']) }
  it 'should not confuse types' do is_expected.to run.with_params(['1', '2', '3'], [1, 2]).and_return([]) end
end
