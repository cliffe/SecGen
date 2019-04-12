require 'spec_helper'

describe 'grep' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it {
    pending("grep does not actually check this, and raises NoMethodError instead")
    is_expected.to run.with_params('one', 'two').and_raise_error(Puppet::ParseError, /first argument not an array/)
  }
  it {
    pending("grep does not actually check this, and raises NoMethodError instead")
    is_expected.to run.with_params(1, 'two').and_raise_error(Puppet::ParseError, /first argument not an array/)
  }
  it { is_expected.to run.with_params('one', 'two', 'three').and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params([], 'two').and_return([]) }
  it { is_expected.to run.with_params(['one', 'two', 'three'], 'two').and_return(['two']) }
  it { is_expected.to run.with_params(['one', 'two', 'three'], 't(wo|hree)').and_return(['two', 'three']) }
  it { is_expected.to run.with_params(['ờאּê', 'ţשּׂỡ', 'ţһŗəè'], 'ţ(שּׂỡ|һŗəè)').and_return(['ţשּׂỡ', 'ţһŗəè']) }
end
