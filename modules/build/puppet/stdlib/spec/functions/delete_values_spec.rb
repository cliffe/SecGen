require 'spec_helper'

describe 'delete_values' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one', 'two', 'three').and_raise_error(Puppet::ParseError) }
  describe 'when the first argument is not a hash' do
    it { is_expected.to run.with_params(1, 'two').and_raise_error(TypeError) }
    it { is_expected.to run.with_params('one', 'two').and_raise_error(TypeError) }
    it { is_expected.to run.with_params([], 'two').and_raise_error(TypeError) }
  end

  describe 'when deleting from a hash' do
    it { is_expected.to run.with_params({}, 'value').and_return({}) }
    it {
      is_expected.to run \
        .with_params({ 'key1' => 'value1' }, 'non-existing value') \
        .and_return('key1' => 'value1')
    }
    it {
      is_expected.to run \
        .with_params({ 'ҝếỵ1 ' => 'νâĺūẹ1', 'ҝếỵ2' => 'value to delete' }, 'value to delete') \
        .and_return('ҝếỵ1 ' => 'νâĺūẹ1')
    }
    it {
      is_expected.to run \
        .with_params({ 'key1' => 'value1', 'key2' => 'νǎŀữ℮ ťớ đêłểťė' }, 'νǎŀữ℮ ťớ đêłểťė') \
        .and_return('key1' => 'value1')
    }
    it {
      is_expected.to run \
        .with_params({ 'key1' => 'value1', 'key2' => 'value to delete', 'key3' => 'value to delete' }, 'value to delete') \
        .and_return('key1' => 'value1')
    }
  end

  it 'leaves the original argument intact' do
    argument = { 'key1' => 'value1', 'key2' => 'value2' }
    original = argument.dup
    _result = subject.call([argument, 'value2'])
    expect(argument).to eq(original)
  end
end
