require 'spec_helper'

describe 'str2saltedsha512' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params('password', 2).and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, %r{Requires a String argument}) }

  context 'when running with a specific seed' do
    # make tests deterministic
    before(:each) { srand(2) }

    it {
      is_expected.to run.with_params('')
                        .and_return('0f8a612f4eeed08e47b3875d00f33c5688f7926298f2d9b5fe19d1323f910bc78b6f7b5892596d2fabaa65e7a8d99b3768c102610cf0432c4827eee01f09451e3fae4f7a')
    }
    it {
      is_expected.to run.with_params('password')
                        .and_return('0f8a612f43134376566c5707718d600effcfb17581fc9d3fa64d7f447dfda317c174ffdb498d2c5bd5c2075dab41c9d7ada5afbdc6b55354980eb5ba61802371e6b64956')
    }
    it {
      is_expected.to run.with_params('verylongpassword')
                        .and_return('0f8a612f7a448537540e062daa8621f9bae326ca8ccb899e1bdb10e7c218cebfceae2530b856662565fdc4d81e986fc50cfbbc46d50436610ed9429ff5e43f2c45b5d039')
    }
  end
end
