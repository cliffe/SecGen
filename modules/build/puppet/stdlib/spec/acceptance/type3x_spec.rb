#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'type3x function' do
  describe 'success' do
    {
      %{type3x({ 'a' => 'hash' })} => 'Hash',
      %{type3x(['array'])}         => 'Array',
      %{type3x(false)}             => 'Boolean',
      %{type3x('asdf')}            => 'String',
      %{type3x(242)}               => 'Integer',
      %{type3x(3.14)}              => 'Float',
    }.each do |pp, type|
      it "with type #{type}" do
        apply_manifest(pp, :catch_failures => true)
      end
    end
  end

  describe 'failure' do
    pp_fail = <<-MANIFEST
      type3x('one','two')
    MANIFEST
    it 'handles improper number of arguments' do
      expect(apply_manifest(pp_fail, :expect_failures => true).stderr).to match(%r{Wrong number of arguments})
    end
  end
end
