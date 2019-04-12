require 'spec_helper'

describe 'empty' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError) }
  it {
    pending("Current implementation ignores parameters after the first.")
    is_expected.to run.with_params('one', 'two').and_raise_error(Puppet::ParseError)
  }
  it { is_expected.to run.with_params(0).and_return(false) }
  it { is_expected.to run.with_params('').and_return(true) }
  it { is_expected.to run.with_params('one').and_return(false) }

  it { is_expected.to run.with_params(AlsoString.new('')).and_return(true) }
  it { is_expected.to run.with_params(AlsoString.new('one')).and_return(false) }

  it { is_expected.to run.with_params([]).and_return(true) }
  it { is_expected.to run.with_params(['one']).and_return(false) }

  it { is_expected.to run.with_params({}).and_return(true) }
  it { is_expected.to run.with_params({'key' => 'value'}).and_return(false) }
end
