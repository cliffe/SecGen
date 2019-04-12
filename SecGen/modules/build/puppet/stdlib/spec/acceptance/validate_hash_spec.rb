#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'validate_hash function' do
  describe 'success' do
    it 'validates a single argument' do
      pp = <<-EOS
      $one = { 'a' => 1 }
      validate_hash($one)
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
    it 'validates an multiple arguments' do
      pp = <<-EOS
      $one = { 'a' => 1 }
      $two = { 'b' => 2 }
      validate_hash($one,$two)
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
    [
      %{validate_hash('{ "not" => "hash" }')},
      %{validate_hash('string')},
      %{validate_hash(["array"])},
      %{validate_hash(undef)}
    ].each do |pp|
      it "rejects #{pp.inspect}" do
        expect(apply_manifest(pp, :expect_failures => true).stderr).to match(//)
      end
    end
  end
  describe 'failure' do
    it 'handles improper number of arguments'
  end
end
