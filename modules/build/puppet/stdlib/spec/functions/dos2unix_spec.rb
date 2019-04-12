require 'spec_helper'

describe 'dos2unix' do
  context 'Checking parameter validity' do
    it { is_expected.not_to eq(nil) }
    it do
      is_expected.to run.with_params.and_raise_error(ArgumentError, /Wrong number of arguments/)
    end
    it do
      is_expected.to run.with_params('one', 'two').and_raise_error(ArgumentError, /Wrong number of arguments/)
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

  context 'Converting from dos to unix format' do
    sample_text    = "Hello\r\nWorld\r\n"
    desired_output = "Hello\nWorld\n"

    it 'should output unix format' do
      should run.with_params(sample_text).and_return(desired_output)
    end
  end

  context 'Internationalization (i18N) values' do
    sample_text_utf8    = "Ħ℮ļłǿ\r\nשׁөŕłđ\r\n"
    desired_output_utf8 = "Ħ℮ļłǿ\nשׁөŕłđ\n"

    sample_text_doublebyte    = "こんにちは\r\n世界\r\n"
    desired_output_doublebyte = "こんにちは\n世界\n"

    it 'should output uft8 string' do
      should run.with_params(sample_text_utf8).and_return(desired_output_utf8)
    end

    it 'should output double byte string' do
      should run.with_params(sample_text_doublebyte).and_return(desired_output_doublebyte)
    end
  end
end
