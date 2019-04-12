require 'spec_helper'

describe 'reject' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params([], 'pattern', 'extra').and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }

  it {
    pending("reject does not actually check this, and raises NoMethodError instead")
    is_expected.to run.with_params('one', 'two').and_raise_error(Puppet::ParseError, /first argument not an array/)
  }
  it {
    pending("reject does not actually check this, and raises NoMethodError instead")
    is_expected.to run.with_params(1, 'two').and_raise_error(Puppet::ParseError, /first argument not an array/)
  }
  it { is_expected.to run.with_params([], 'two').and_return([]) }
  it { is_expected.to run.with_params(['one', 'two', 'three'], 'two').and_return(['one', 'three']) }
  it { is_expected.to run.with_params(['one', 'two', 'three'], 't(wo|hree)').and_return(['one']) }
  it { is_expected.to run.with_params(['όŉệ', 'ţщồ', 'ţңяέέ'], 'ţ(щồ|ңяέέ)').and_return(['όŉệ']) }
end
