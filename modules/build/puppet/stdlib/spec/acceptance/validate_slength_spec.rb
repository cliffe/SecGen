#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'validate_slength function' do
  describe 'success' do
    pp1 = <<-DOC
      $one = 'discombobulate'
      $two = 17
      validate_slength($one,$two)
    DOC
    it 'validates a single string max' do
      apply_manifest(pp1, :catch_failures => true)
    end

    pp2 = <<-DOC
      $one = ['discombobulate', 'moo']
      $two = 17
      validate_slength($one,$two)
    DOC
    it 'validates multiple string maxes' do
      apply_manifest(pp2, :catch_failures => true)
    end

    pp3 = <<-DOC
      $one = ['discombobulate', 'moo']
      $two = 17
      $three = 3
      validate_slength($one,$two,$three)
    DOC
    it 'validates min/max of  strings in array' do
      apply_manifest(pp3, :catch_failures => true)
    end

    pp4 = <<-DOC
      $one = 'discombobulate'
      $two = 1
      validate_slength($one,$two)
    DOC
    it 'validates a single string max of incorrect length' do
      apply_manifest(pp4, :expect_failures => true)
    end

    pp5 = <<-DOC
      $one = ['discombobulate', 'moo']
      $two = 3
      validate_slength($one,$two)
    DOC
    it 'validates multiple string maxes of incorrect length' do
      apply_manifest(pp5, :expect_failures => true)
    end

    pp6 = <<-DOC
      $one = ['discombobulate', 'moo']
      $two = 17
      $three = 10
      validate_slength($one,$two,$three)
    DOC
    it 'validates multiple strings min/maxes of incorrect length' do
      apply_manifest(pp6, :expect_failures => true)
    end
  end
  describe 'failure' do
    it 'handles improper number of arguments'
    it 'handles improper first argument type'
    it 'handles non-strings in array of first argument'
    it 'handles improper second argument type'
    it 'handles improper third argument type'
    it 'handles negative ranges'
    it 'handles improper ranges'
  end
end
