require 'spec_helper'

describe 'parseyaml' do
  it 'should exist' do
    is_expected.not_to eq(nil)
  end

  it 'should raise an error if called without any arguments' do
    is_expected.to run.with_params().
                       and_raise_error(/wrong number of arguments/i)
  end

  context 'with correct YAML data' do
    it 'should be able to parse a YAML data with a String' do
      is_expected.to run.with_params('--- just a string').
                         and_return('just a string')
      is_expected.to run.with_params('just a string').
                         and_return('just a string')
    end

    it 'should be able to parse YAML data with a Hash' do
      is_expected.to run.with_params("---\na: '1'\nb: '2'\n").
                         and_return({'a' => '1', 'b' => '2'})
    end

    it 'should be able to parse YAML data with an Array' do
      is_expected.to run.with_params("---\n- a\n- b\n- c\n").
                         and_return(['a', 'b', 'c'])
    end

    it 'should be able to parse YAML data with a mixed structure' do
      is_expected.to run.with_params("---\na: '1'\nb: 2\nc:\n  d:\n  - :a\n  - true\n  - false\n").
                         and_return({'a' => '1', 'b' => 2, 'c' => {'d' => [:a, true, false]}})
    end

    it 'should be able to parse YAML data with a UTF8 and double byte characters' do
      is_expected.to run.with_params("---\na: ×\nこれ: 記号\nです:\n  ©:\n  - Á\n  - ß\n").
          and_return({"a"=>"×", "これ"=>"記号", "です"=>{"©"=>["Á", "ß"]} })
    end

    it 'should not return the default value if the data was parsed correctly' do
      is_expected.to run.with_params("---\na: '1'\n", 'default_value').
                         and_return({'a' => '1'})
    end

  end

  context 'on a modern ruby', :unless => RUBY_VERSION == '1.8.7' do
    it 'should raise an error with invalid YAML and no default' do
      is_expected.to run.with_params('["one"').
                         and_raise_error(Psych::SyntaxError)
    end
  end

    context 'when running on ruby 1.8.7, which does not have Psych', :if => RUBY_VERSION == '1.8.7' do
      it 'should raise an error with invalid YAML and no default' do
        is_expected.to run.with_params('["one"').
          and_raise_error(ArgumentError)
      end
    end

  context 'with incorrect YAML data' do
    it 'should support a structure for a default value' do
      is_expected.to run.with_params('', {'a' => '1'}).
                         and_return({'a' => '1'})
    end

    [1, 1.2, nil, true, false, [], {}, :yaml].each do |value|
      it "should return the default value for an incorrect #{value.inspect} (#{value.class}) parameter" do
        is_expected.to run.with_params(value, 'default_value').
                           and_return('default_value')
      end
    end

    context 'when running on modern rubies', :unless => RUBY_VERSION == '1.8.7' do
      ['---', '...', '*8', ''].each do |value|
        it "should return the default value for an incorrect #{value.inspect} string parameter" do
          is_expected.to run.with_params(value, 'default_value').
                             and_return('default_value')
        end
      end
    end

  end

end
