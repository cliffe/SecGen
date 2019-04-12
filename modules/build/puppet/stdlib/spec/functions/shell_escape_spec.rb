require 'spec_helper'

describe 'shell_escape' do
  it { is_expected.not_to eq(nil) }

  describe 'signature validation' do
    it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
    it { is_expected.to run.with_params('foo', 'bar').and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  end

  describe 'stringification' do
    it { is_expected.to run.with_params(10).and_return('10') }
    it { is_expected.to run.with_params(false).and_return('false') }
  end

  describe 'escaping' do
    it { is_expected.to run.with_params('foo').and_return('foo') }
    it { is_expected.to run.with_params('foo bar').and_return('foo\ bar') }
    it { is_expected.to run.with_params('~`!@#$%^&*()_+-=[]\{}|;\':",./<>?')
           .and_return('\~\`\!@\#\$\%\^\&\*\(\)_\+-\=\[\]\\\\\{\}\|\;\\\':\",./\<\>\?') }
  end

  context 'should run with UTF8 and double byte characters' do
      it { is_expected.to run.with_params('スペー スを含むテ  キスト').and_return('\\ス\\ペ\\ー\\ \\ス\\を\\含\\む\\テ\\ \\ \\キ\\ス\\ト') }
      it { is_expected.to run.with_params('μťƒ 8  ŧĕχť').and_return('\\μ\\ť\\ƒ\\ 8\\ \\ \\ŧ\\ĕ\\χ\\ť') }
  end
end
