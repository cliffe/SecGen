require 'spec_helper'

describe 'delete_at' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one', 1).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(1, 1).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(['one'], 'two').and_raise_error(Puppet::ParseError) }
  it {
    pending('Current implementation ignores parameters after the first two.')
    is_expected.to run.with_params(['one'], 0, 1).and_raise_error(Puppet::ParseError)
  }

  describe 'argument validation' do
    it { is_expected.to run.with_params([0, 1, 2], 3).and_raise_error(Puppet::ParseError) }
  end

  it { is_expected.to run.with_params([0, 1, 2], 1).and_return([0, 2]) }
  it { is_expected.to run.with_params([0, 1, 2], -1).and_return([0, 1]) }
  it { is_expected.to run.with_params([0, 1, 2], -4).and_return([0, 1, 2]) }
  it { is_expected.to run.with_params(%w[ƒờở βāř ьầż], 1).and_return(%w[ƒờở ьầż]) }

  it 'leaves the original array intact' do
    argument = [1, 2, 3]
    original = argument.dup
    _result = subject.call([argument, 2])
    expect(argument).to eq(original)
  end
end
