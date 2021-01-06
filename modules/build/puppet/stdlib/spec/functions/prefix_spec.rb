require 'spec_helper'

describe 'prefix' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it {
    pending('Current implementation ignores parameters after the second.')
    is_expected.to run.with_params([], 'a', '').and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i)
  }
  it { is_expected.to run.with_params('', '').and_raise_error(Puppet::ParseError, %r{expected first argument to be an Array or a Hash}) }
  it { is_expected.to run.with_params([], 2).and_raise_error(Puppet::ParseError, %r{expected second argument to be a String}) }
  it { is_expected.to run.with_params([]).and_return([]) }
  it { is_expected.to run.with_params(['one', 2]).and_return(%w[one 2]) }
  it { is_expected.to run.with_params(['ớņệ', 2]).and_return(%w[ớņệ 2]) }
  it { is_expected.to run.with_params([], '').and_return([]) }
  it { is_expected.to run.with_params([''], '').and_return(['']) }
  it { is_expected.to run.with_params(['one'], 'pre').and_return(['preone']) }
  it { is_expected.to run.with_params(%w[one two three], 'pre').and_return(%w[preone pretwo prethree]) }
  it { is_expected.to run.with_params({}).and_return({}) }
  it { is_expected.to run.with_params('key1' => 'value1', 2 => 3).and_return('key1' => 'value1', '2' => 3) }
  it { is_expected.to run.with_params({}, '').and_return({}) }
  it { is_expected.to run.with_params({ 'key' => 'value' }, '').and_return('key' => 'value') }
  it { is_expected.to run.with_params({ 'key' => 'value' }, 'pre').and_return('prekey' => 'value') }
  it {
    is_expected.to run \
      .with_params({ 'key1' => 'value1', 'key2' => 'value2', 'key3' => 'value3' }, 'pre') \
      .and_return('prekey1' => 'value1', 'prekey2' => 'value2', 'prekey3' => 'value3')
  }
end
