require 'spec_helper'

describe 'has_key' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params('one', 'two', 'three').and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params('one', 'two').and_raise_error(Puppet::ParseError, %r{expects the first argument to be a hash}) }
  it { is_expected.to run.with_params(1, 'two').and_raise_error(Puppet::ParseError, %r{expects the first argument to be a hash}) }
  it { is_expected.to run.with_params([], 'two').and_raise_error(Puppet::ParseError, %r{expects the first argument to be a hash}) }

  it { is_expected.to run.with_params({ 'key' => 'value' }, 'key').and_return(true) }
  it { is_expected.to run.with_params({}, 'key').and_return(false) }
  it { is_expected.to run.with_params({ 'key' => 'value' }, 'not a key').and_return(false) }

  context 'with UTF8 and double byte characters' do
    it { is_expected.to run.with_params({ 'κéỳ ' => '٧ậļųể' }, 'κéỳ ').and_return(true) }
    it { is_expected.to run.with_params({ 'キー' => '٧ậļųể' }, 'キー').and_return(true) }
  end
end
