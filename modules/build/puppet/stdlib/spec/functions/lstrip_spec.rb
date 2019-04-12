require 'spec_helper'

describe 'lstrip' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it {
    pending("Current implementation ignores parameters after the first.")
    is_expected.to run.with_params('', '').and_raise_error(Puppet::ParseError, /wrong number of arguments/i)
  }
  it { is_expected.to run.with_params({}).and_raise_error(Puppet::ParseError, /Requires either array or string to work with/) }
  it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, /Requires either array or string to work with/) }
  it { is_expected.to run.with_params('').and_return('') }
  it { is_expected.to run.with_params(' ').and_return('') }
  it { is_expected.to run.with_params('     ').and_return('') }
  it { is_expected.to run.with_params("\t").and_return('') }
  it { is_expected.to run.with_params("\t ").and_return('') }
  it { is_expected.to run.with_params('one').and_return('one') }
  it { is_expected.to run.with_params(' one').and_return('one') }
  it { is_expected.to run.with_params('     one').and_return('one') }
  it { is_expected.to run.with_params("\tone").and_return('one') }
  it { is_expected.to run.with_params("\t one").and_return('one') }
  it { is_expected.to run.with_params('one ').and_return('one ') }
  it { is_expected.to run.with_params(' one ').and_return('one ') }
  it { is_expected.to run.with_params('     one ').and_return('one ') }
  it { is_expected.to run.with_params('     ǿňè ').and_return('ǿňè ') }
  it { is_expected.to run.with_params("\tone ").and_return('one ') }
  it { is_expected.to run.with_params("\t one ").and_return('one ') }
  it { is_expected.to run.with_params("one \t").and_return("one \t") }
  it { is_expected.to run.with_params(" one \t").and_return("one \t") }
  it { is_expected.to run.with_params("     one \t").and_return("one \t") }
  it { is_expected.to run.with_params("\tone \t").and_return("one \t") }
  it { is_expected.to run.with_params("\t one \t").and_return("one \t") }
  it { is_expected.to run.with_params(' o n e ').and_return('o n e ') }
  it { is_expected.to run.with_params(AlsoString.new(' one ')).and_return('one ') }
end
