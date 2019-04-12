require 'spec_helper'

describe 'clamp' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params([]).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(12, 88, 71, 190).and_raise_error(Puppet::ParseError, /Wrong number of arguments, need three to clamp/) }
  it { is_expected.to run.with_params('12string', 88, 15).and_raise_error(Puppet::ParseError, /Required explicit numeric/) }
  it { is_expected.to run.with_params(1, 2, {'a' => 55}).and_raise_error(Puppet::ParseError, /The Hash type is not allowed/) }
  it { is_expected.to run.with_params('24', [575, 187]).and_return(187) }
  it { is_expected.to run.with_params([4, 3, '99']).and_return(4) }
  it { is_expected.to run.with_params(16, 750, 88).and_return(88) }
  it { is_expected.to run.with_params([3, 873], 73).and_return(73) }
  it { is_expected.to run.with_params([4], 8, 75).and_return(8) }
  it { is_expected.to run.with_params([6], [31], 9911).and_return(31) }
end
