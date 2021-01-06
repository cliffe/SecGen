require 'spec_helper'

describe 'zip' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params([]).and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it {
    pending('Current implementation ignores parameters after the third.')
    is_expected.to run.with_params([], [], true, []).and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i)
  }
  it { is_expected.to run.with_params([], []).and_return([]) }
  it { is_expected.to run.with_params([1, 2, 3], [4, 5, 6]).and_return([[1, 4], [2, 5], [3, 6]]) }
  it { is_expected.to run.with_params([1, 2, 3], [4, 5, 6], false).and_return([[1, 4], [2, 5], [3, 6]]) }
  it { is_expected.to run.with_params([1, 2, 3], [4, 5, 6], true).and_return([1, 4, 2, 5, 3, 6]) }

  context 'with UTF8 and double byte characters' do
    it { is_expected.to run.with_params(%w[ầ ь ć], %w[đ ề ƒ]).and_return([%w[ầ đ], %w[ь ề], %w[ć ƒ]]) }
    it { is_expected.to run.with_params(%w[ペ 含 値], %w[ッ 文 イ]).and_return([%w[ペ ッ], %w[含 文], %w[値 イ]]) }
  end
end
