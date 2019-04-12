require 'spec_helper'

describe 'delete' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params([]).and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params([], 'two') }
  it { is_expected.to run.with_params([], 'two', 'three').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params(1, 'two').and_raise_error(TypeError) }

  describe 'deleting from an array' do
    it { is_expected.to run.with_params([], '').and_return([]) }
    it { is_expected.to run.with_params([], 'two').and_return([]) }
    it { is_expected.to run.with_params(['two'], 'two').and_return([]) }
    it { is_expected.to run.with_params(['two', 'two'], 'two').and_return([]) }
    it { is_expected.to run.with_params(['ab', 'b', 'c', 'b'], 'b').and_return(['ab', 'c']) }
    it { is_expected.to run.with_params(['one', 'two', 'three'], 'four').and_return(['one', 'two', 'three']) }
    it { is_expected.to run.with_params(['one', 'two', 'three'], 'e').and_return(['one', 'two', 'three']) }
    it { is_expected.to run.with_params(['one', 'two', 'three'], 'two').and_return(['one', 'three']) }
    it { is_expected.to run.with_params(['two', 'one', 'two', 'three', 'two'], 'two').and_return(['one', 'three']) }
    it { is_expected.to run.with_params(['one', 'two', 'three', 'two'], ['one', 'two']).and_return(['three']) }
    it { is_expected.to run.with_params(['ồאּẻ', 'ŧẅơ', 'ŧңŗё℮', 'ŧẅơ'], ['ồאּẻ', 'ŧẅơ']).and_return(['ŧңŗё℮']) }
  end

  describe 'deleting from a string' do
    it { is_expected.to run.with_params('', '').and_return('') }
    it { is_expected.to run.with_params('bar', '').and_return('bar') }
    it { is_expected.to run.with_params('', 'bar').and_return('') }
    it { is_expected.to run.with_params('bar', 'bar').and_return('') }
    it { is_expected.to run.with_params('barbar', 'bar').and_return('') }
    it { is_expected.to run.with_params('barfoobar', 'bar').and_return('foo') }
    it { is_expected.to run.with_params('foobarbabarz', 'bar').and_return('foobaz') }
    it { is_expected.to run.with_params('foobarbabarz', ['foo', 'bar']).and_return('baz') }
    it { is_expected.to run.with_params('ƒōōβậяβậβậяź', ['ƒōō', 'βậя']).and_return('βậź') }

    it { is_expected.to run.with_params('barfoobar', ['barbar', 'foo']).and_return('barbar') }
    it { is_expected.to run.with_params('barfoobar', ['foo', 'barbar']).and_return('') }
  end

  describe 'deleting from an array' do
    it { is_expected.to run.with_params({}, '').and_return({}) }
    it { is_expected.to run.with_params({}, 'key').and_return({}) }
    it { is_expected.to run.with_params({'key' => 'value'}, 'key').and_return({}) }
    it { is_expected.to run \
      .with_params({'key1' => 'value1', 'key2' => 'value2', 'key3' => 'value3'}, 'key2') \
      .and_return( {'key1' => 'value1', 'key3' => 'value3'})
    }
    it { is_expected.to run \
      .with_params({'key1' => 'value1', 'key2' => 'value2', 'key3' => 'value3'}, ['key1', 'key2']) \
      .and_return( {'key3' => 'value3'})
    }
    it { is_expected.to run \
      .with_params({'ĸəұ1' => 'νãŀủĕ1', 'ĸəұ2' => 'νãŀủĕ2', 'ĸəұ3' => 'νãŀủĕ3'}, ['ĸəұ1', 'ĸəұ2']) \
      .and_return( {'ĸəұ3' => 'νãŀủĕ3'})
    }
  end

  it "should leave the original array intact" do
    argument1 = ['one','two','three']
    original1 = argument1.dup
    result = subject.call([argument1,'two'])
    expect(argument1).to eq(original1)
  end
  it "should leave the original string intact" do
    argument1 = 'onetwothree'
    original1 = argument1.dup
    result = subject.call([argument1,'two'])
    expect(argument1).to eq(original1)
  end
  it "should leave the original hash intact" do
    argument1 = {'key1' => 'value1', 'key2' => 'value2', 'key3' => 'value3'}
    original1 = argument1.dup
    result = subject.call([argument1,'key2'])
    expect(argument1).to eq(original1)
  end
end
