require 'spec_helper'

describe 'glob' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('').and_return([]) }
  it { is_expected.to run.with_params(['']).and_return([]) }
  it { is_expected.to run.with_params(['', '']).and_return([]) }
  it { is_expected.to run.with_params(['/etc/xyzxyzxyz', '/etcxyzxyzxyz']).and_return([]) }
end
