require 'spec_helper'

describe 'sort' do
  describe 'signature validation' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
    it { is_expected.to run.with_params([], 'extra').and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
    it { pending('stricter input checking'); is_expected.to run.with_params({}).and_raise_error(Puppet::ParseError, /requires string or array/) }
    it { pending('stricter input checking'); is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, /requires string or array/) }
    it { pending('stricter input checking'); is_expected.to run.with_params(true).and_raise_error(Puppet::ParseError, /requires string or array/) }
  end

  context 'when called with an array' do
    it { is_expected.to run.with_params([]).and_return([]) }
    it { is_expected.to run.with_params(['a']).and_return(['a']) }
    it { is_expected.to run.with_params(['c', 'b', 'a']).and_return(['a', 'b', 'c']) }
  end

  context 'when called with a string' do
    it { is_expected.to run.with_params('').and_return('') }
    it { is_expected.to run.with_params('a').and_return('a') }
    it { is_expected.to run.with_params('cbda').and_return('abcd') }
  end
end
