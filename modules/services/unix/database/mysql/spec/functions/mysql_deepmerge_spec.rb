#! /usr/bin/env ruby -S rspec # rubocop:disable Lint/ScriptPermission

require 'spec_helper'

describe 'mysql::deepmerge' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'throws error with no arguments' do
    is_expected.to run.with_params.and_raise_error(Puppet::ParseError)
  end

  it 'throws error with only one argument' do
    is_expected.to run.with_params('one' => 1).and_raise_error(Puppet::ParseError)
  end

  it 'accepts empty strings as puppet undef' do
    is_expected.to run.with_params({}, '')
  end

  # rubocop:disable RSpec/NamedSubject
  index_values = ['one', 'two', 'three']
  expected_values_one = ['1', '2', '2']
  it 'is able to mysql_deepmerge two hashes' do
    new_hash = subject.execute({ 'one' => '1', 'two' => '1' }, 'two' => '2', 'three' => '2')
    index_values.each_with_index do |index, expected|
      expect(new_hash[index]).to eq(expected_values_one[expected])
    end
  end

  it 'mysql_deepmerges multiple hashes' do
    hash = subject.execute({ 'one' => 1 }, { 'one' => '2' }, 'one' => '3')
    expect(hash['one']).to eq('3')
  end

  it 'accepts empty hashes' do
    is_expected.to run.with_params({}, {}, {}).and_return({})
  end

  expected_values_two = [1, 2, 'four' => 4]
  it 'mysql_deepmerges subhashes' do
    hash = subject.execute({ 'one' => 1 }, 'two' => 2, 'three' => { 'four' => 4 })
    index_values.each_with_index do |index, expected|
      expect(hash[index]).to eq(expected_values_two[expected])
    end
  end

  it 'appends to subhashes' do
    hash = subject.execute({ 'one' => { 'two' => 2 } }, 'one' => { 'three' => 3 })
    expect(hash['one']).to eq('two' => 2, 'three' => 3)
  end

  expected_values_three = [1, 'dos', { 'four' => 4, 'five' => 5 }]
  it 'appends to subhashes 2' do
    hash = subject.execute({ 'one' => 1, 'two' => 2, 'three' => { 'four' => 4 } }, 'two' => 'dos', 'three' => { 'five' => 5 })
    index_values.each_with_index do |index, expected|
      expect(hash[index]).to eq(expected_values_three[expected])
    end
  end

  index_values_two = ['key1', 'key2']
  expected_values_four = [{ 'a' => 1, 'b' => 99 }, 'c' => 3]
  it 'appends to subhashes 3' do
    hash = subject.execute({ 'key1' => { 'a' => 1, 'b' => 2 }, 'key2' => { 'c' => 3 } }, 'key1' => { 'b' => 99 })
    index_values_two.each_with_index do |index, expected|
      expect(hash[index]).to eq(expected_values_four[expected])
    end
  end

  it 'equates keys mod dash and underscore #value' do
    hash = subject.execute({ 'a-b-c' => 1 }, 'a_b_c' => 10)
    expect(hash['a_b_c']).to eq(10)
  end
  it 'equates keys mod dash and underscore #not' do
    hash = subject.execute({ 'a-b-c' => 1 }, 'a_b_c' => 10)
    expect(hash).not_to have_key('a-b-c')
  end

  index_values_three = ['a_b_c', 'b-c-d']
  expected_values_five = [10, { 'e-f-g' => 3, 'c_d_e' => 12 }]
  index_values_error = ['a-b-c', 'b_c_d']
  index_values_three.each_with_index do |index, expected|
    it 'keeps style of the last when keys are equal mod dash and underscore #value' do
      hash = subject.execute({ 'a-b-c' => 1, 'b_c_d' => { 'c-d-e' => 2, 'e-f-g' => 3 } }, 'a_b_c' => 10, 'b-c-d' => { 'c_d_e' => 12 })
      expect(hash[index]).to eq(expected_values_five[expected])
    end
    it 'keeps style of the last when keys are equal mod dash and underscore #not' do
      hash = subject.execute({ 'a-b-c' => 1, 'b_c_d' => { 'c-d-e' => 2, 'e-f-g' => 3 } }, 'a_b_c' => 10, 'b-c-d' => { 'c_d_e' => 12 })
      expect(hash).not_to have_key(index_values_error[expected])
    end
  end
  # rubocop:enable RSpec/NamedSubject
end
