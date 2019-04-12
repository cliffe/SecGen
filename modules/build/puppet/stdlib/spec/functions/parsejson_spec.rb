require 'spec_helper'

describe 'parsejson' do
  it 'should exist' do
    is_expected.not_to eq(nil)
  end

  it 'should raise an error if called without any arguments' do
    is_expected.to run.with_params().
                       and_raise_error(/wrong number of arguments/i)
  end

  context 'with correct JSON data' do

    it 'should be able to parse JSON data with a Hash' do
      is_expected.to run.with_params('{"a":"1","b":"2"}').
                         and_return({'a'=>'1', 'b'=>'2'})
    end

    it 'should be able to parse JSON data with an Array' do
      is_expected.to run.with_params('["a","b","c"]').
                         and_return(['a', 'b', 'c'])
    end

    it 'should be able to parse empty JSON values' do
      is_expected.to run.with_params('[]').
                         and_return([])
      is_expected.to run.with_params('{}').
                         and_return({})
    end

    it 'should be able to parse JSON data with a mixed structure' do
      is_expected.to run.with_params('{"a":"1","b":2,"c":{"d":[true,false]}}').
                         and_return({'a' =>'1', 'b' => 2, 'c' => { 'd' => [true, false] } })
    end

    it 'should be able to parse JSON data with a UTF8 and double byte characters' do
      is_expected.to run.with_params('{"×":"これ","ý":"記号","です":{"©":["Á","ß"]}}').
          and_return({'×' =>'これ', 'ý' => '記号', 'です' => { '©' => ['Á', 'ß'] } })
    end

    it 'should not return the default value if the data was parsed correctly' do
      is_expected.to run.with_params('{"a":"1"}', 'default_value').
                         and_return({'a' => '1'})
    end

  end

  context 'with incorrect JSON data' do
    it 'should raise an error with invalid JSON and no default' do
      is_expected.to run.with_params('').
                         and_raise_error(PSON::ParserError)
    end

    it 'should support a structure for a default value' do
      is_expected.to run.with_params('', {'a' => '1'}).
                         and_return({'a' => '1'})
    end

    ['', 1, 1.2, nil, true, false, [], {}, :yaml].each do |value|
      it "should return the default value for an incorrect #{value.inspect} (#{value.class}) parameter" do
        is_expected.to run.with_params(value, 'default_value').
                           and_return('default_value')
      end
    end

  end

end
