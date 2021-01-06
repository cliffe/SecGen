#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'intersection function' do
  describe 'success' do
    pp = <<-DOC
      $a = ['aaa','bbb','ccc']
      $b = ['bbb','ccc','ddd','eee']
      $c = ['bbb','ccc']
      $o = intersection($a,$b)
      if $o == $c {
        notify { 'output correct': }
      }
    DOC
    it 'intersections arrays' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
    it 'intersections empty arrays'
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-arrays'
  end
end
