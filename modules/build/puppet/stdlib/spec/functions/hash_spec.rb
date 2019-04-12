require 'spec_helper'

describe 'hash' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it {
    pending("Current implementation ignores parameters after the first.")
    is_expected.to run.with_params([], 'two').and_raise_error(Puppet::ParseError, /wrong number of arguments/i)
  }
  it { is_expected.to run.with_params(['one']).and_raise_error(Puppet::ParseError, /Unable to compute/) }
  it { is_expected.to run.with_params([]).and_return({}) }
  it { is_expected.to run.with_params(['key1', 'value1']).and_return({ 'key1' => 'value1' }) }
  it { is_expected.to run.with_params(['κ℮ұ1', '√āĺűẻ1']).and_return({ 'κ℮ұ1' => '√āĺűẻ1' }) }
  it { is_expected.to run.with_params(['key1', 'value1', 'key2', 'value2']).and_return({ 'key1' => 'value1', 'key2' => 'value2' }) }
end
