require 'spec_helper'

describe 'shell_split' do
  it { is_expected.not_to eq(nil) }

  describe 'signature validation' do
    it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
    it { is_expected.to run.with_params('foo', 'bar').and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  end

  describe 'stringification' do
    it { is_expected.to run.with_params(10).and_return(['10']) }
    it { is_expected.to run.with_params(false).and_return(['false']) }
  end

  describe 'shell line spliting' do
    it { is_expected.to run.with_params('foo').and_return(['foo']) }
    it { is_expected.to run.with_params('foo bar').and_return(['foo', 'bar']) }
    it { is_expected.to run.with_params('\~\`\!@\#\$\%\^\&\*\(\)_\+-\=\[\]\\\\\{\}\|\;\\\':\",./\<\>\?')
         .and_return(['~`!@#$%^&*()_+-=[]\{}|;\':",./<>?']) }
    it { is_expected.to run.with_params('\~\`\!@\#\$ \%\^\&\*\(\)_\+-\= \[\]\\\\\{\}\|\;\\\':\" ,./\<\>\?')
         .and_return(['~`!@#$', '%^&*()_+-=', '[]\{}|;\':"', ',./<>?']) }

     context 'should run with UTF8 and double byte characters' do
        it { is_expected.to run.with_params('\\μ\\ť\\ƒ 8 \\ŧ\\ĕ\\χ\\ť').and_return(['μťƒ', '8',  'ŧĕχť']) }
        it { is_expected.to run.with_params('\\ス\\ペ\\ー \\ス\\を\\含\\む\\テ \\ \\キ\\ス\\ト').and_return(['スペー', 'スを含むテ', ' キスト']) }
    end
  end
end
