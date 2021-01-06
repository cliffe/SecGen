require 'spec_helper'

describe 'unix2dos' do
  context 'when checking parameter validity' do
    it { is_expected.not_to eq(nil) }
    it do
      is_expected.to run.with_params.and_raise_error(ArgumentError, %r{Wrong number of arguments})
    end
    it do
      is_expected.to run.with_params('one', 'two').and_raise_error(ArgumentError, %r{Wrong number of arguments})
    end
    it do
      is_expected.to run.with_params([]).and_raise_error(Puppet::ParseError)
    end
    it do
      is_expected.to run.with_params({}).and_raise_error(Puppet::ParseError)
    end
    it do
      is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError)
    end
  end

  context 'when converting from unix to dos format' do
    sample_text    = "Hello\nWorld\n"
    desired_output = "Hello\r\nWorld\r\n"

    it 'outputs dos format' do
      is_expected.to run.with_params(sample_text).and_return(desired_output)
    end
  end

  context 'when converting from dos to dos format' do
    sample_text    = "Hello\r\nWorld\r\n"
    desired_output = "Hello\r\nWorld\r\n"

    it 'outputs dos format' do
      is_expected.to run.with_params(sample_text).and_return(desired_output)
    end
  end
end
