require 'spec_helper'

describe 'sprintf_hash' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  context 'with param count' do
    it 'fails with no arguments' do
      is_expected.to run.with_params.and_raise_error(ArgumentError, %r{expects 2 arguments}i)
    end
    it 'fails with 1 argument' do
      is_expected.to run.with_params('').and_raise_error(ArgumentError, %r{expects 2 arguments}i)
    end
    it 'fails with too many arguments' do
      is_expected.to run.with_params('', '', '').and_raise_error(ArgumentError, %r{expects 2 arguments}i)
    end
  end

  context 'with param type' do
    it 'fails with wrong format type' do
      is_expected.to run.with_params(false, {}).and_raise_error(ArgumentError, %r{parameter 'format' expects a String value}i)
    end
    it 'fails with wrong arguments type' do
      is_expected.to run.with_params('', false).and_raise_error(ArgumentError, %r{parameter 'arguments' expects a Hash value}i)
    end
  end

  it 'prints formats with name placeholders' do
    is_expected.to run.with_params('string %<foo>s and integer %<bar>b', 'foo' => '_foo_', 'bar' => 5) # rubocop:disable Style/FormatStringToken : Template tokens needed for purposes of test
                      .and_return('string _foo_ and integer 101')
  end
end
