require 'spec_helper'

describe 'shell_join' do
  it { is_expected.not_to eq(nil) }

  describe 'signature validation' do
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it { is_expected.to run.with_params(['foo'], ['bar']).and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it { is_expected.to run.with_params('foo').and_raise_error(Puppet::ParseError, %r{is not an Array}i) }
  end

  describe 'shell argument joining' do
    it { is_expected.to run.with_params(['foo']).and_return('foo') }
    it { is_expected.to run.with_params(%w[foo bar]).and_return('foo bar') }
    it { is_expected.to run.with_params(['foo', 'bar baz']).and_return('foo bar\ baz') }
    it {
      is_expected.to run.with_params(['~`!@#$', '%^&*()_+-=', '[]\{}|;\':"', ',./<>?'])
                        .and_return('\~\`\!@\#\$ \%\^\&\*\(\)_\+-\= \[\]\\\\\{\}\|\;\\\':\" ,./\<\>\?')
    }

    context 'with UTF8 and double byte characters' do
      it { is_expected.to run.with_params(%w[μťƒ 8 ŧĕχť]).and_return('\\μ\\ť\\ƒ 8 \\ŧ\\ĕ\\χ\\ť') }
      it { is_expected.to run.with_params(['スペー', 'スを含むテ', ' キスト']).and_return('\\ス\\ペ\\ー \\ス\\を\\含\\む\\テ \\ \\キ\\ス\\ト') }
    end
  end

  describe 'stringification' do
    it { is_expected.to run.with_params([10, false, 'foo']).and_return('10 false foo') }
  end
end
