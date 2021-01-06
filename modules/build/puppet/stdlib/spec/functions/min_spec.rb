require 'spec_helper'

describe 'min' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params(1).and_return(1) }
  it { is_expected.to run.with_params(1, 2).and_return(1) }
  it { is_expected.to run.with_params(1, 2, 3).and_return(1) }
  it { is_expected.to run.with_params(3, 2, 1).and_return(1) }
  it { is_expected.to run.with_params(12, 8).and_return(8) }
  it { is_expected.to run.with_params('one').and_return('one') }
  it { is_expected.to run.with_params('one', 'two').and_return('one') }
  it { is_expected.to run.with_params('one', 'two', 'three').and_return('one') }
  it { is_expected.to run.with_params('three', 'two', 'one').and_return('one') }

  describe 'implementation artifacts' do
    it { is_expected.to run.with_params(1, 'one').and_return(1) }
    it { is_expected.to run.with_params('1', 'one').and_return('1') }
    it { is_expected.to run.with_params('1.3e1', '1.4e0').and_return('1.3e1') }
    it { is_expected.to run.with_params(1.3e1, 1.4e0).and_return(1.4e0) }
  end
end
