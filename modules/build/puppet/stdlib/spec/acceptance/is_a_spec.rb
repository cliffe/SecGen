#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

if get_puppet_version =~ /^4/
  describe 'is_a function' do
    it 'should match a string' do
      pp = <<-EOS
      if 'hello world'.is_a(String) {
        notify { 'output correct': }
      }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Notice: output correct/)
      end
    end

    it 'should not match a integer as string' do
      pp = <<-EOS
      if 5.is_a(String) {
        notify { 'output wrong': }
      }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).not_to match(/Notice: output wrong/)
      end
    end
  end
end
