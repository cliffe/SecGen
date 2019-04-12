#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'validate_bool function' do
  describe 'success' do
    it 'validates a single argument' do
      pp = <<-EOS
      $one = true
      validate_bool($one)
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
    it 'validates an multiple arguments' do
      pp = <<-EOS
      $one = true
      $two = false
      validate_bool($one,$two)
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
    [
      %{validate_bool('true')},
      %{validate_bool('false')},
      %{validate_bool([true])},
      %{validate_bool(undef)}
    ].each do |pp|
      it "rejects #{pp.inspect}" do
        expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/is not a boolean\.  It looks to be a/)
      end
    end
  end
  describe 'failure' do
    it 'handles improper number of arguments'
  end
end
