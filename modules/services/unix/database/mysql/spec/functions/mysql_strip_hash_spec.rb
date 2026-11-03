require 'spec_helper'

describe 'mysql::strip_hash' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'raises a ArgumentError if there is less than 1 arguments' do
    is_expected.to run.with_params.and_raise_error(ArgumentError)
  end

  it 'raises a ArgumentError if there is more than 1 arguments' do
    is_expected.to run.with_params({ 'foo' => 1 }, 'bar' => 2).and_raise_error(ArgumentError)
  end

  it 'raises a ArgumentError if argument is not a hash' do
    is_expected.to run.with_params('foo').and_raise_error(ArgumentError)
  end

  it 'passes a hash without blanks through' do
    is_expected.to run.with_params('one' => 1, 'two' => 2, 'three' => 3).and_return('one' => 1, 'two' => 2, 'three' => 3)
  end

  it 'removes blank hash elements' do
    is_expected.to run.with_params('one' => 1, 'two' => '', 'three' => nil, 'four' => 4).and_return('one' => 1, 'three' => nil, 'four' => 4)
  end
end
