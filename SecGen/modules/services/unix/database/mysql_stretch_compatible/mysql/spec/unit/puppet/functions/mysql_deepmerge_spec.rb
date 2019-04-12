#! /usr/bin/env ruby -S rspec # rubocop:disable Lint/ScriptPermission

require 'spec_helper'

describe Puppet::Parser::Functions.function(:mysql_deepmerge) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  describe 'when calling mysql_deepmerge from puppet' do
    it 'does not compile when no arguments are passed' do
      skip('Fails on 2.6.x, see bug #15912') if Puppet.version =~ %r{^2\.6\.}
      Puppet[:code] = '$x = mysql_deepmerge()'
      expect {
        scope.compiler.compile
      }.to raise_error(Puppet::ParseError, %r{wrong number of arguments})
    end

    it 'does not compile when 1 argument is passed' do
      skip('Fails on 2.6.x, see bug #15912') if Puppet.version =~ %r{^2\.6\.}
      Puppet[:code] = "$my_hash={'one' => 1}\n$x = mysql_deepmerge($my_hash)"
      expect {
        scope.compiler.compile
      }.to raise_error(Puppet::ParseError, %r{wrong number of arguments})
    end
  end

  describe 'when calling mysql_deepmerge on the scope instance' do
    it 'accepts empty strings as puppet undef' do
      expect { scope.function_mysql_deepmerge([{}, '']) }.not_to raise_error
    end

    index_values = ['one', 'two', 'three']
    expected_values_one = ['1', '2', '2']
    it 'is able to mysql_deepmerge two hashes' do
      new_hash = scope.function_mysql_deepmerge([{ 'one' => '1', 'two' => '1' }, { 'two' => '2', 'three' => '2' }])
      index_values.each_with_index do |index, expected|
        expect(new_hash[index]).to eq(expected_values_one[expected])
      end
    end

    it 'mysql_deepmerges multiple hashes' do
      hash = scope.function_mysql_deepmerge([{ 'one' => 1 }, { 'one' => '2' }, { 'one' => '3' }])
      expect(hash['one']).to eq('3')
    end

    it 'accepts empty hashes' do
      expect(scope.function_mysql_deepmerge([{}, {}, {}])).to eq({})
    end

    expected_values_two = [1, 2, 'four' => 4]
    it 'mysql_deepmerges subhashes' do
      hash = scope.function_mysql_deepmerge([{ 'one' => 1 }, { 'two' => 2, 'three' => { 'four' => 4 } }])
      index_values.each_with_index do |index, expected|
        expect(hash[index]).to eq(expected_values_two[expected])
      end
    end

    it 'appends to subhashes' do
      hash = scope.function_mysql_deepmerge([{ 'one' => { 'two' => 2 } }, { 'one' => { 'three' => 3 } }])
      expect(hash['one']).to eq('two' => 2, 'three' => 3)
    end

    expected_values_three = [1, 'dos', { 'four' => 4, 'five' => 5 }]
    it 'appends to subhashes 2' do
      hash = scope.function_mysql_deepmerge([{ 'one' => 1, 'two' => 2, 'three' => { 'four' => 4 } }, { 'two' => 'dos', 'three' => { 'five' => 5 } }])
      index_values.each_with_index do |index, expected|
        expect(hash[index]).to eq(expected_values_three[expected])
      end
    end

    index_values_two = ['key1', 'key2']
    expected_values_four = [{ 'a' => 1, 'b' => 99 }, 'c' => 3]
    it 'appends to subhashes 3' do
      hash = scope.function_mysql_deepmerge([{ 'key1' => { 'a' => 1, 'b' => 2 }, 'key2' => { 'c' => 3 } }, { 'key1' => { 'b' => 99 } }])
      index_values_two.each_with_index do |index, expected|
        expect(hash[index]).to eq(expected_values_four[expected])
      end
    end

    it 'equates keys mod dash and underscore #value' do
      hash = scope.function_mysql_deepmerge([{ 'a-b-c' => 1 }, { 'a_b_c' => 10 }])
      expect(hash['a_b_c']).to eq(10)
    end
    it 'equates keys mod dash and underscore #not' do
      hash = scope.function_mysql_deepmerge([{ 'a-b-c' => 1 }, { 'a_b_c' => 10 }])
      expect(hash).not_to have_key('a-b-c')
    end

    index_values_three = ['a_b_c', 'b-c-d']
    expected_values_five = [10, { 'e-f-g' => 3, 'c_d_e' => 12 }]
    index_values_error = ['a-b-c', 'b_c_d']
    index_values_three.each_with_index do |index, expected|
      it 'keeps style of the last when keys are euqal mod dash and underscore #value' do
        hash = scope.function_mysql_deepmerge([{ 'a-b-c' => 1, 'b_c_d' => { 'c-d-e' => 2, 'e-f-g' => 3 } }, { 'a_b_c' => 10, 'b-c-d' => { 'c_d_e' => 12 } }])
        expect(hash[index]).to eq(expected_values_five[expected])
      end
      it 'keeps style of the last when keys are euqal mod dash and underscore #not' do
        hash = scope.function_mysql_deepmerge([{ 'a-b-c' => 1, 'b_c_d' => { 'c-d-e' => 2, 'e-f-g' => 3 } }, { 'a_b_c' => 10, 'b-c-d' => { 'c_d_e' => 12 } }])
        expect(hash).not_to have_key(index_values_error[expected])
      end
    end
  end
end
