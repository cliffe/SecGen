require 'spec_helper'

describe 'pick_default' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(RuntimeError, %r{Must receive at least one argument}) }

  it { is_expected.to run.with_params('one', 'two').and_return('one') }
  it { is_expected.to run.with_params('ớņệ', 'ťωơ').and_return('ớņệ') }
  it { is_expected.to run.with_params('', 'two').and_return('two') }
  it { is_expected.to run.with_params(:undef, 'two').and_return('two') }
  it { is_expected.to run.with_params(:undefined, 'two').and_return('two') }
  it { is_expected.to run.with_params(nil, 'two').and_return('two') }

  ['', :undef, :undefined, nil, {}, [], 1, 'default'].each do |value|
    describe "when providing #{value.inspect} as default" do
      it { is_expected.to run.with_params('one', value).and_return('one') }
      it { is_expected.to run.with_params('ớņệ', value).and_return('ớņệ') }
      it { is_expected.to run.with_params([], value).and_return([]) }
      it { is_expected.to run.with_params({}, value).and_return({}) }
      it { is_expected.to run.with_params(value, value).and_return(value) }
      it { is_expected.to run.with_params(:undef, value).and_return(value) }
      it { is_expected.to run.with_params(:undefined, value).and_return(value) }
      it { is_expected.to run.with_params(nil, value).and_return(value) }
    end
  end
end
