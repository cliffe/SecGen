require 'spec_helper'

describe 'unique' do
  describe 'signature validation' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
    it {
      pending("Current implementation ignores parameters after the first.")
      is_expected.to run.with_params([], 'extra').and_raise_error(Puppet::ParseError, /wrong number of arguments/i)
    }
    it { is_expected.to run.with_params({}).and_raise_error(Puppet::ParseError, /Requires either array or string to work/) }
    it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, /Requires either array or string to work/) }
    it { is_expected.to run.with_params(true).and_raise_error(Puppet::ParseError, /Requires either array or string to work/) }
  end

  context 'when called with an array' do
    it { is_expected.to run.with_params([]).and_return([]) }
    it { is_expected.to run.with_params(['a']).and_return(['a']) }
    it { is_expected.to run.with_params(['a', 'b', 'a']).and_return(['a', 'b']) }
    it { is_expected.to run.with_params(['ã', 'ъ', 'ã']).and_return(['ã', 'ъ']) }
  end

  context 'when called with a string' do
    it { is_expected.to run.with_params('').and_return('') }
    it { is_expected.to run.with_params('a').and_return('a') }
    it { is_expected.to run.with_params('aaba').and_return('ab') }
    it { is_expected.to run.with_params('ããъã').and_return('ãъ') }
  end
end
