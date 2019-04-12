require 'spec_helper'

describe 'join' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it {
    pending("Current implementation ignores parameters after the second.")
    is_expected.to run.with_params([], '', '').and_raise_error(Puppet::ParseError, /wrong number of arguments/i)
  }
  it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError, /Requires array to work with/) }
  it { is_expected.to run.with_params([], 2).and_raise_error(Puppet::ParseError, /Requires string to work with/) }

  it { is_expected.to run.with_params([]).and_return('') }
  it { is_expected.to run.with_params([], ':').and_return('') }
  it { is_expected.to run.with_params(['one']).and_return('one') }
  it { is_expected.to run.with_params(['one'], ':').and_return('one') }
  it { is_expected.to run.with_params(['one', 'two', 'three']).and_return('onetwothree') }
  it { is_expected.to run.with_params(['one', 'two', 'three'], ':').and_return('one:two:three') }
  it { is_expected.to run.with_params(['ōŋể', 'ŧשợ', 'ţђŕẽё'], ':').and_return('ōŋể:ŧשợ:ţђŕẽё') }
end
