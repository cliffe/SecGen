#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'dirname function' do
  describe 'success' do
    context 'with absolute path' do
      pp1 = <<-DOC
        $a = '/path/to/a/file.txt'
        $b = '/path/to/a'
        $o = dirname($a)
        if $o == $b {
          notify { 'output correct': }
        }
      DOC
      it 'returns the dirname' do
        apply_manifest(pp1, :catch_failures => true) do |r|
          expect(r.stdout).to match(%r{Notice: output correct})
        end
      end
    end
    context 'with relative path' do
      pp2 = <<-DOC
        $a = 'path/to/a/file.txt'
        $b = 'path/to/a'
        $o = dirname($a)
        if $o == $b {
          notify { 'output correct': }
        }
      DOC
      it 'returns the dirname' do
        apply_manifest(pp2, :catch_failures => true) do |r|
          expect(r.stdout).to match(%r{Notice: output correct})
        end
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
  end
end
