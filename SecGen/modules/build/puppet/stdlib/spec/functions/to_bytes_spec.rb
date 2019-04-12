require 'spec_helper'

describe 'to_bytes' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params('1', 'extras').and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params([]).and_raise_error(TypeError, /(can't convert|no implicit conversion of) Array (in)?to String/) }
  it { is_expected.to run.with_params({}).and_raise_error(TypeError, /(can't convert|no implicit conversion of) Hash (in)?to String/) }
  it { is_expected.to run.with_params(true).and_raise_error(TypeError, /(can't convert|no implicit conversion of) (TrueClass|true) (in)?to String/) }

  describe 'when passing numbers' do
    it { is_expected.to run.with_params(0).and_return(0) }
    it { is_expected.to run.with_params(1).and_return(1) }
    it { is_expected.to run.with_params(-1).and_return(-1) }
    it { is_expected.to run.with_params(1.1).and_return(1.1) }
    it { is_expected.to run.with_params(-1.1).and_return(-1.1) }
  end

  describe 'when passing numbers as strings' do
    describe 'without a unit' do
      it { is_expected.to run.with_params('1').and_return(1) }
      it { is_expected.to run.with_params('-1').and_return(-1) }
      # these are so wrong
      it { is_expected.to run.with_params('1.1').and_return(1) }
      it { is_expected.to run.with_params('-1.1').and_return(-1) }
    end

    describe 'with a unit' do
      it { is_expected.to run.with_params('1k').and_return(1024) }
      it { is_expected.to run.with_params('-1kB').and_return(-1024) }
      it { is_expected.to run.with_params('1k').and_return(1024) }
      it { is_expected.to run.with_params('1M').and_return(1024*1024) }
      it { is_expected.to run.with_params('1G').and_return(1024*1024*1024) }
      it { is_expected.to run.with_params('1T').and_return(1024*1024*1024*1024) }
      it { is_expected.to run.with_params('1P').and_return(1024*1024*1024*1024*1024) }
      it { is_expected.to run.with_params('1E').and_return(1024*1024*1024*1024*1024*1024) }
      it { is_expected.to run.with_params('1.5e3M').and_return(1572864000) }

      it { is_expected.to run.with_params('4k').and_return(4*1024) }
      it { is_expected.to run.with_params('-4kB').and_return(4*-1024) }
      it { is_expected.to run.with_params('4k').and_return(4*1024) }
      it { is_expected.to run.with_params('4M').and_return(4*1024*1024) }
      it { is_expected.to run.with_params('4G').and_return(4*1024*1024*1024) }
      it { is_expected.to run.with_params('4T').and_return(4*1024*1024*1024*1024) }
      it { is_expected.to run.with_params('4P').and_return(4*1024*1024*1024*1024*1024) }
      it { is_expected.to run.with_params('4E').and_return(4*1024*1024*1024*1024*1024*1024) }

      # these are so wrong
      it { is_expected.to run.with_params('1.0001 k').and_return(1024) }
      it { is_expected.to run.with_params('-1.0001 kB').and_return(-1024) }
    end

    describe 'with a unknown unit' do
      it { is_expected.to run.with_params('1KB').and_raise_error(Puppet::ParseError, /Unknown prefix/) }
      it { is_expected.to run.with_params('1K').and_raise_error(Puppet::ParseError, /Unknown prefix/) }
      it { is_expected.to run.with_params('1mb').and_raise_error(Puppet::ParseError, /Unknown prefix/) }
      it { is_expected.to run.with_params('1m').and_raise_error(Puppet::ParseError, /Unknown prefix/) }
      it { is_expected.to run.with_params('1%').and_raise_error(Puppet::ParseError, /Unknown prefix/) }
      it { is_expected.to run.with_params('1 p').and_raise_error(Puppet::ParseError, /Unknown prefix/) }
    end
  end

  # these are so wrong
  describe 'when passing random stuff' do
    it { is_expected.to run.with_params('-1....1').and_return(-1) }
    it { is_expected.to run.with_params('-1.e.e.e.1').and_return(-1) }
    it { is_expected.to run.with_params('-1+1').and_return(-1) }
    it { is_expected.to run.with_params('1-1').and_return(1) }
    it { is_expected.to run.with_params('1 kaboom').and_return(1024) }
    it { is_expected.to run.with_params('kaboom').and_return(0) }
  end
end
