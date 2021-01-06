require 'spec_helper'

describe 'range' do
  it { is_expected.not_to eq(nil) }

  describe 'signature validation in puppet3', :unless => RSpec.configuration.puppet_future do
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it {
      pending('Current implementation ignores parameters after the third.')
      is_expected.to run.with_params(1, 2, 3, 4).and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i)
    }
    it { is_expected.to run.with_params('1..2..3').and_raise_error(Puppet::ParseError, %r{Unable to compute range}i) }
    it { is_expected.to run.with_params('').and_raise_error(Puppet::ParseError, %r{Unknown range format}i) }
  end

  describe 'signature validation in puppet4', :if => RSpec.configuration.puppet_future do
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params.and_raise_error(ArgumentError)
    }
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params('').and_raise_error(ArgumentError)
    }
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params({}).and_raise_error(ArgumentError)
    }
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params([]).and_raise_error(ArgumentError)
    }
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params(true).and_raise_error(ArgumentError)
    }
    it {
      is_expected.to run.with_params(1, 2, 'foo').and_raise_error(ArgumentError)
    }
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params(1, 2, []).and_raise_error(ArgumentError)
    }
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params(1, 2, {}).and_raise_error(ArgumentError)
    }
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params(1, 2, true).and_raise_error(ArgumentError)
    }
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params(1, 2, 3, 4).and_raise_error(ArgumentError)
    }
    it {
      pending 'the puppet 4 implementation'
      is_expected.to run.with_params('1..2..3').and_raise_error(ArgumentError)
    }
  end

  context 'with characters as bounds' do
    it { is_expected.to run.with_params('d', 'a').and_return([]) }
    it { is_expected.to run.with_params('a', 'a').and_return(['a']) }
    it { is_expected.to run.with_params('a', 'b').and_return(%w[a b]) }
    it { is_expected.to run.with_params('a', 'd').and_return(%w[a b c d]) }
    it { is_expected.to run.with_params('a', 'd', 1).and_return(%w[a b c d]) }
    it { is_expected.to run.with_params('a', 'd', '1').and_return(%w[a b c d]) }
    it { is_expected.to run.with_params('a', 'd', 2).and_return(%w[a c]) }
    it { is_expected.to run.with_params('a', 'd', -2).and_return(%w[a c]) }
    it { is_expected.to run.with_params('a', 'd', 3).and_return(%w[a d]) }
    it { is_expected.to run.with_params('a', 'd', 4).and_return(['a']) }
  end

  context 'with strings as bounds' do
    it { is_expected.to run.with_params('onea', 'oned').and_return(%w[onea oneb onec oned]) }
    it { is_expected.to run.with_params('two', 'one').and_return([]) }
    it { is_expected.to run.with_params('true', 'false').and_return([]) }
    it { is_expected.to run.with_params('false', 'true').and_return(['false']) }
  end

  context 'with integers as bounds' do
    it { is_expected.to run.with_params(4, 1).and_return([]) }
    it { is_expected.to run.with_params(1, 1).and_return([1]) }
    it { is_expected.to run.with_params(1, 2).and_return([1, 2]) }
    it { is_expected.to run.with_params(1, 4).and_return([1, 2, 3, 4]) }
    it { is_expected.to run.with_params(1, 4, 1).and_return([1, 2, 3, 4]) }
    it { is_expected.to run.with_params(1, 4, '1').and_return([1, 2, 3, 4]) }
    it { is_expected.to run.with_params(1, 4, 2).and_return([1, 3]) }
    it { is_expected.to run.with_params(1, 4, -2).and_return([1, 3]) }
    it { is_expected.to run.with_params(1, 4, 3).and_return([1, 4]) }
    it { is_expected.to run.with_params(1, 4, 4).and_return([1]) }
  end

  context 'with integers as strings as bounds' do
    it { is_expected.to run.with_params('4', '1').and_return([]) }
    it { is_expected.to run.with_params('1', '1').and_return([1]) }
    it { is_expected.to run.with_params('1', '2').and_return([1, 2]) }
    it { is_expected.to run.with_params('1', '4').and_return([1, 2, 3, 4]) }
    it { is_expected.to run.with_params('1', '4', 1).and_return([1, 2, 3, 4]) }
    it { is_expected.to run.with_params('1', '4', '1').and_return([1, 2, 3, 4]) }
    it { is_expected.to run.with_params('1', '4', 2).and_return([1, 3]) }
    it { is_expected.to run.with_params('1', '4', -2).and_return([1, 3]) }
    it { is_expected.to run.with_params('1', '4', 3).and_return([1, 4]) }
    it { is_expected.to run.with_params('1', '4', 4).and_return([1]) }
  end

  context 'with prefixed numbers as strings as bounds' do
    it { is_expected.to run.with_params('host01', 'host04').and_return(%w[host01 host02 host03 host04]) }
    it { is_expected.to run.with_params('01', '04').and_return([1, 2, 3, 4]) }
  end

  context 'with prefixed numbers as utf8 strings as bounds' do
    it { is_expected.to run.with_params('ħөŝŧ01', 'ħөŝŧ04').and_return(%w[ħөŝŧ01 ħөŝŧ02 ħөŝŧ03 ħөŝŧ04]) }
  end

  context 'with prefixed numbers as double byte character strings as bounds' do
    it { is_expected.to run.with_params('ホスト01', 'ホスト04').and_return(%w[ホスト01 ホスト02 ホスト03 ホスト04]) }
  end

  context 'with dash-range syntax' do
    it { is_expected.to run.with_params('4-1').and_return([]) }
    it { is_expected.to run.with_params('1-1').and_return([1]) }
    it { is_expected.to run.with_params('1-2').and_return([1, 2]) }
    it { is_expected.to run.with_params('1-4').and_return([1, 2, 3, 4]) }
  end

  context 'with two-dot-range syntax' do
    it { is_expected.to run.with_params('4..1').and_return([]) }
    it { is_expected.to run.with_params('1..1').and_return([1]) }
    it { is_expected.to run.with_params('1..2').and_return([1, 2]) }
    it { is_expected.to run.with_params('1..4').and_return([1, 2, 3, 4]) }
  end

  context 'with three-dot-range syntax' do
    it { is_expected.to run.with_params('4...1').and_return([]) }
    it { is_expected.to run.with_params('1...1').and_return([]) }
    it { is_expected.to run.with_params('1...2').and_return([1]) }
    it { is_expected.to run.with_params('1...3').and_return([1, 2]) }
    it { is_expected.to run.with_params('1...5').and_return([1, 2, 3, 4]) }
  end

  describe 'when passing mixed arguments as bounds' do
    it {
      pending('these bounds should not be allowed as ruby will OOM hard. e.g. `(\'host0\'..\'hosta\').to_a` has 3239930 elements on ruby 1.9, adding more \'0\'s and \'a\'s increases that exponentially') # rubocop:disable Metrics/LineLength : unable to cut line to required length
      is_expected.to run.with_params('0', 'a').and_raise_error(Puppet::ParseError, %r{cannot interpolate between numeric and non-numeric bounds})
    }
    it {
      pending('these bounds should not be allowed as ruby will OOM hard. e.g. `(\'host0\'..\'hosta\').to_a` has 3239930 elements on ruby 1.9, adding more \'0\'s and \'a\'s increases that exponentially') # rubocop:disable Metrics/LineLength : unable to cut line to required length
      is_expected.to run.with_params(0, 'a').and_raise_error(Puppet::ParseError, %r{cannot interpolate between numeric and non-numeric bounds})
    }
    it {
      pending('these bounds should not be allowed as ruby will OOM hard. e.g. `(\'host0\'..\'hosta\').to_a` has 3239930 elements on ruby 1.9, adding more \'0\'s and \'a\'s increases that exponentially') # rubocop:disable Metrics/LineLength : unable to cut line to required length
      is_expected.to run.with_params('h0', 'ha').and_raise_error(Puppet::ParseError, %r{cannot interpolate between numeric and non-numeric bounds})
    }
  end
end
