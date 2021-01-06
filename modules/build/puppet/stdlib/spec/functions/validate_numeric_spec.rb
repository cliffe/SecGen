require 'spec_helper'

describe 'validate_numeric' do
  after(:each) do
    ENV.delete('STDLIB_LOG_DEPRECATIONS')
  end

  # Checking for deprecation warning
  it 'displays a single deprecation' do
    ENV['STDLIB_LOG_DEPRECATIONS'] = 'true'
    scope.expects(:warning).with(includes('This method is deprecated'))
    is_expected.to run.with_params(3)
  end

  describe 'signature validation' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it { is_expected.to run.with_params(1, 2, 3, 4).and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }

    [true, 'true', false, 'false', 'iAmAString', '1test', '1 test', 'test 1', 'test 1 test', {}, { 'key' => 'value' }, { 1 => 2 }, '', :undef, 'x'].each do |invalid|
      it { is_expected.to run.with_params(invalid).and_raise_error(Puppet::ParseError, %r{to be a Numeric}) }
      it { is_expected.to run.with_params(invalid, 10.0).and_raise_error(Puppet::ParseError, %r{to be a Numeric}) }
      it { is_expected.to run.with_params(invalid, 10.0, -10.0).and_raise_error(Puppet::ParseError, %r{to be a Numeric}) }
    end

    context 'when running on modern rubies', :unless => RUBY_VERSION == '1.8.7' do
      it { is_expected.to run.with_params([0, 1, 2, { 1 => 2 }, 3, 4], 10, -10).and_raise_error(Puppet::ParseError, %r{to be a Numeric}) }
    end

    context 'when running on ruby, which munges hashes weirdly', :if => RUBY_VERSION == '1.8.7' do
      it { is_expected.to run.with_params([0, 1, 2, { 1 => 2 }, 3, 4], 10, -10).and_raise_error(Puppet::ParseError) }
      it { is_expected.to run.with_params([0, 1, 2, { 0 => 2 }, 3, 4], 10, -10).and_raise_error(Puppet::ParseError) }
    end

    it { is_expected.to run.with_params(1, '').and_raise_error(Puppet::ParseError, %r{to be unset or a Numeric}) }
    it { is_expected.to run.with_params(1, 2, '').and_raise_error(Puppet::ParseError, %r{to be unset or a Numeric}) }
    it { is_expected.to run.with_params(1, 2, 3).and_raise_error(Puppet::ParseError, %r{second argument to be larger than third argument}) }
  end

  context 'with no range constraints' do
    it { is_expected.to run.with_params(1) }
    it { is_expected.to run.with_params(-1) }
    it { is_expected.to run.with_params('1') }
    it { is_expected.to run.with_params('-1') }
    it { is_expected.to run.with_params([1, 2, 3, 4]) }
    it { is_expected.to run.with_params([1, '2', '3', 4]) }
  end

  context 'with a maximum limit of 10.0' do
    describe 'rejects numbers greater than the limit' do
      it { is_expected.to run.with_params(11, 10.0).and_raise_error(Puppet::ParseError, %r{to be smaller or equal}) }
      it { is_expected.to run.with_params(100, 10.0).and_raise_error(Puppet::ParseError, %r{to be smaller or equal}) }
      it { is_expected.to run.with_params(2**65, 10.0).and_raise_error(Puppet::ParseError, %r{to be smaller or equal}) }
      it { is_expected.to run.with_params([1, 2, 10.0, 100], 10.0).and_raise_error(Puppet::ParseError, %r{to be smaller or equal}) }
    end

    describe 'accepts numbers less or equal to the limit' do
      it { is_expected.to run.with_params(10.0, 10.0) }
      it { is_expected.to run.with_params(1, 10.0) }
      it { is_expected.to run.with_params(-1, 10.0) }
      it { is_expected.to run.with_params('1', 10.0) }
      it { is_expected.to run.with_params('-1', 10.0) }
      it { is_expected.to run.with_params([1, 2, 3, 4], 10.0) }
      it { is_expected.to run.with_params([1, '2', '3', 4], 10.0) }
    end
  end

  context 'with a minimum limit of -10.0' do
    describe 'rejects numbers greater than the upper limit' do
      it { is_expected.to run.with_params(11, 10.0, -10.0).and_raise_error(Puppet::ParseError, %r{to be smaller or equal}) }
      it { is_expected.to run.with_params(100, 10.0, -10.0).and_raise_error(Puppet::ParseError, %r{to be smaller or equal}) }
      it { is_expected.to run.with_params(2**65, 10.0, -10.0).and_raise_error(Puppet::ParseError, %r{to be smaller or equal}) }
      it { is_expected.to run.with_params([1, 2, 10.0, 100], 10.0, -10.0).and_raise_error(Puppet::ParseError, %r{to be smaller or equal}) }
    end

    describe 'rejects numbers smaller than the lower limit' do
      it { is_expected.to run.with_params(-11, 10.0, -10.0).and_raise_error(Puppet::ParseError, %r{to be greater or equal}) }
      it { is_expected.to run.with_params(-100, 10.0, -10.0).and_raise_error(Puppet::ParseError, %r{to be greater or equal}) }
      it { is_expected.to run.with_params(-2**65, 10.0, -10.0).and_raise_error(Puppet::ParseError, %r{to be greater or equal}) }
      it { is_expected.to run.with_params([-10.0, 1, 2, 10.0, -100], 10.0, -10.0).and_raise_error(Puppet::ParseError, %r{to be greater or equal}) }
    end

    describe 'accepts numbers between and including the limits' do
      it { is_expected.to run.with_params(10.0, 10.0, -10.0) }
      it { is_expected.to run.with_params(-10.0, 10.0, -10.0) }
      it { is_expected.to run.with_params(1, 10.0, -10.0) }
      it { is_expected.to run.with_params(-1, 10.0, -10.0) }
      it { is_expected.to run.with_params('1', 10.0, -10.0) }
      it { is_expected.to run.with_params('-1', 10.0, -10.0) }
      it { is_expected.to run.with_params([1, 2, 3, 4], 10.0, -10.0) }
      it { is_expected.to run.with_params([1, '2', '3', 4], 10.0, -10.0) }
    end
  end

  it { is_expected.to run.with_params(10.0, 10.0, 10.0) }

  describe 'empty upper limit is interpreted as infinity' do
    it { is_expected.to run.with_params(11, '', 10.0) }
  end
end
