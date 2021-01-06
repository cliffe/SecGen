require 'spec_helper'

describe 'capitalize' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(100).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one').and_return('One') }
  it { is_expected.to run.with_params('one two').and_return('One two') }
  it { is_expected.to run.with_params('ONE TWO').and_return('One two') }

  it { is_expected.to run.with_params(AlsoString.new('one')).and_return('One') }
  it { is_expected.to run.with_params([]).and_return([]) }
  it { is_expected.to run.with_params(%w[one two]).and_return(%w[One Two]) }
  it { is_expected.to run.with_params(['one', 1, 'two']).and_return(['One', 1, 'Two']) }
end
