require 'spec_helper'

describe 'is_mac_address' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params([], []).and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params('00:a0:1f:12:7f:a0').and_return(true) }
  it { is_expected.to run.with_params('00:A0:1F:12:7F:A0').and_return(true) }
  it { is_expected.to run.with_params('00:00:00:00:00:0g').and_return(false) }
  it { is_expected.to run.with_params('').and_return(false) }
  it { is_expected.to run.with_params('one').and_return(false) }

  context 'with  UTF8 and double byte characters' do
    it { is_expected.to run.with_params('ƒốưř').and_return(false) }
    it { is_expected.to run.with_params('三+').and_return(false) }
  end

  it {
    pending 'should properly typecheck its arguments'
    is_expected.to run.with_params(1).and_return(false)
  }
  it {
    pending 'should properly typecheck its arguments'
    is_expected.to run.with_params({}).and_return(false)
  }
  it {
    pending 'should properly typecheck its arguments'
    is_expected.to run.with_params([]).and_return(false)
  }
end
