#! /usr/bin/env ruby -S rspec # rubocop:disable Lint/ScriptPermission : Rubocop Mistake???
require 'spec_helper_acceptance'

if return_puppet_version =~ %r{^4}
  describe 'is_a function' do
    pp1 = <<-DOC
      if 'hello world'.is_a(String) {
        notify { 'output correct': }
      }
    DOC
    it 'matches a string' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      if 5.is_a(String) {
        notify { 'output wrong': }
      }
    DOC
    it 'does not match a integer as string' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).not_to match(%r{Notice: output wrong})
      end
    end
  end
end
