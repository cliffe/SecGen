require 'spec_helper'

describe 'str2bool' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it {
    pending("Current implementation ignores parameters after the first.")
    is_expected.to run.with_params('true', 'extra').and_raise_error(Puppet::ParseError, /wrong number of arguments/i)
  }
  it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError, /Unknown type of boolean given/) }

  describe 'when testing values that mean "true"' do
    [ 'TRUE','1', 't', 'y', 'true', 'yes', true ].each do |value|
      it { is_expected.to run.with_params(value).and_return(true) }
    end
  end

  describe 'when testing values that mean "false"' do
    [ 'FALSE','', '0', 'f', 'n', 'false', 'no', false, 'undef', 'undefined' ].each do |value|
      it { is_expected.to run.with_params(value).and_return(false) }
    end
  end
end
