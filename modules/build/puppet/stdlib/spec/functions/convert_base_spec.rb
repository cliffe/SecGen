require 'spec_helper'

describe 'convert_base' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('asdf').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('asdf', 'moo', 'cow').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(['1'], '2').and_raise_error(Puppet::ParseError, %r{argument must be either a string or an integer}) }
  it { is_expected.to run.with_params('1', ['2']).and_raise_error(Puppet::ParseError, %r{argument must be either a string or an integer}) }
  it { is_expected.to run.with_params('1', 1).and_raise_error(Puppet::ParseError, %r{base must be at least 2 and must not be greater than 36}) }
  it { is_expected.to run.with_params('1', 37).and_raise_error(Puppet::ParseError, %r{base must be at least 2 and must not be greater than 36}) }

  it 'raises a ParseError if argument 1 is a string that does not correspond to an integer in base 10' do
    is_expected.to run.with_params('ten', 6).and_raise_error(Puppet::ParseError, %r{argument must be an integer or a string corresponding to an integer in base 10})
  end

  it 'raises a ParseError if argument 2 is a string and does not correspond to an integer in base 10' do
    is_expected.to run.with_params(100, 'hex').and_raise_error(Puppet::ParseError, %r{argument must be an integer or a string corresponding to an integer in base 10})
  end

  it { is_expected.to run.with_params('11', '16').and_return('b') }
  it { is_expected.to run.with_params('35', '36').and_return('z') }
  it { is_expected.to run.with_params(5, 2).and_return('101') }
end
