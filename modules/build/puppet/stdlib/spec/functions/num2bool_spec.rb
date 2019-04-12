require 'spec_helper'

describe 'num2bool' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params(1, 2).and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params('abc').and_raise_error(Puppet::ParseError, /does not look like a number/) }
  it { is_expected.to run.with_params(1).and_return(true) }
  it { is_expected.to run.with_params('1').and_return(true) }
  it { is_expected.to run.with_params(1.5).and_return(true) }
  it { is_expected.to run.with_params('1.5').and_return(true) }
  it { is_expected.to run.with_params(-1).and_return(false) }
  it { is_expected.to run.with_params('-1').and_return(false) }
  it { is_expected.to run.with_params(-1.5).and_return(false) }
  it { is_expected.to run.with_params('-1.5').and_return(false) }
  it { is_expected.to run.with_params(0).and_return(false) }
  it { is_expected.to run.with_params('0').and_return(false) }
  it { is_expected.to run.with_params([]).and_return(false) }
  it { is_expected.to run.with_params('[]').and_raise_error(Puppet::ParseError, /does not look like a number/) }
  it { is_expected.to run.with_params({}).and_return(false) }
  it { is_expected.to run.with_params('{}').and_raise_error(Puppet::ParseError, /does not look like a number/) }
end
