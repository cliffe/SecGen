require 'spec_helper'

describe 'max' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params(1).and_return(1) }
  it { is_expected.to run.with_params(1, 2).and_return(2) }
  it { is_expected.to run.with_params(1, 2, 3).and_return(3) }
  it { is_expected.to run.with_params(3, 2, 1).and_return(3) }
  it { is_expected.to run.with_params('one').and_return('one') }
  it { is_expected.to run.with_params('one', 'two').and_return('two') }
  it { is_expected.to run.with_params('one', 'two', 'three').and_return('two') }
  it { is_expected.to run.with_params('three', 'two', 'one').and_return('two') }

  describe 'implementation artifacts' do
    it { is_expected.to run.with_params(1, 'one').and_return('one') }
    it { is_expected.to run.with_params('1', 'one').and_return('one') }
    it { is_expected.to run.with_params('1.3e1', '1.4e0').and_return('1.4e0') }
    it { is_expected.to run.with_params(1.3e1, 1.4e0).and_return(1.3e1) }
  end
end
