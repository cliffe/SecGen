require 'spec_helper'

describe 'parseyaml' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'raises an error if called without any arguments' do
    is_expected.to run.with_params
                      .and_raise_error(%r{wrong number of arguments}i)
  end

  context 'with correct YAML data' do
    it 'is able to parse a YAML data with a String' do
      actual_array = ['--- just a string', 'just a string']
      actual_array.each do |actual|
        is_expected.to run.with_params(actual).and_return('just a string')
      end
    end

    it 'is able to parse YAML data with a Hash' do
      is_expected.to run.with_params("---\na: '1'\nb: '2'\n")
                        .and_return('a' => '1', 'b' => '2')
    end

    it 'is able to parse YAML data with an Array' do
      is_expected.to run.with_params("---\n- a\n- b\n- c\n")
                        .and_return(%w[a b c])
    end

    it 'is able to parse YAML data with a mixed structure' do
      is_expected.to run.with_params("---\na: '1'\nb: 2\nc:\n  d:\n  - :a\n  - true\n  - false\n")
                        .and_return('a' => '1', 'b' => 2, 'c' => { 'd' => [:a, true, false] })
    end

    it 'is able to parse YAML data with a UTF8 and double byte characters' do
      is_expected.to run.with_params("---\na: ×\nこれ: 記号\nです:\n  ©:\n  - Á\n  - ß\n")
                        .and_return('a' => '×', 'これ' => '記号', 'です' => { '©' => %w[Á ß] })
    end

    it 'does not return the default value if the data was parsed correctly' do
      is_expected.to run.with_params("---\na: '1'\n", 'default_value')
                        .and_return('a' => '1')
    end
  end

  context 'on a modern ruby', :unless => RUBY_VERSION == '1.8.7' do
    it 'raises an error with invalid YAML and no default' do
      is_expected.to run.with_params('["one"')
                        .and_raise_error(Psych::SyntaxError)
    end
  end

  context 'when running on ruby 1.8.7, which does not have Psych', :if => RUBY_VERSION == '1.8.7' do
    it 'raises an error with invalid YAML and no default' do
      is_expected.to run.with_params('["one"')
                        .and_raise_error(ArgumentError)
    end
  end

  context 'with incorrect YAML data' do
    it 'supports a structure for a default value' do
      is_expected.to run.with_params('', 'a' => '1')
                        .and_return('a' => '1')
    end

    [1, 1.2, nil, true, false, [], {}, :yaml].each do |value|
      it "should return the default value for an incorrect #{value.inspect} (#{value.class}) parameter" do
        is_expected.to run.with_params(value, 'default_value')
                          .and_return('default_value')
      end
    end

    context 'when running on modern rubies', :unless => RUBY_VERSION == '1.8.7' do
      ['---', '...', '*8', ''].each do |value|
        it "should return the default value for an incorrect #{value.inspect} string parameter" do
          is_expected.to run.with_params(value, 'default_value')
                            .and_return('default_value')
        end
      end
    end
  end
end
