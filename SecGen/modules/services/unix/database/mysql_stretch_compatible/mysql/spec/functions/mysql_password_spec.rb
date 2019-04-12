require 'spec_helper'

describe 'mysql::password' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'raises a ArgumentError if there is less than 1 arguments' do
    is_expected.to run.with_params.and_raise_error(ArgumentError)
  end

  it 'raises a ArgumentError if there is more than 1 arguments' do
    is_expected.to run.with_params('foo', 'bar').and_raise_error(ArgumentError)
  end

  it 'converts password into a hash' do
    is_expected.to run.with_params('password').and_return('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19')
  end

  it 'converts an empty password into a empty string' do
    is_expected.to run.with_params('').and_return('')
  end

  it 'does not convert a password that is already a hash' do
    is_expected.to run.with_params('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19').and_return('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19')
  end
end
