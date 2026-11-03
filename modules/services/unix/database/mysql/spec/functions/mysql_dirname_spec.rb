require 'spec_helper'

describe 'mysql::dirname' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'raises a ArgumentError if there is less than 1 arguments' do
    is_expected.to run.with_params.and_raise_error(ArgumentError)
  end

  it 'raises a ArgumentError if there is more than 1 arguments' do
    is_expected.to run.with_params('foo', 'bar').and_raise_error(ArgumentError)
  end

  it 'returns path of file' do
    is_expected.to run.with_params('spec/functions/mysql_dirname_spec.rb').and_return('spec/functions')
  end
end
