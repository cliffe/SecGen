#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'merge function' do
  describe 'success' do
    pp = <<-DOC
      $a = {'one' => 1, 'two' => 2, 'three' => { 'four' => 4 } }
      $b = {'two' => 'dos', 'three' => { 'five' => 5 } }
      $o = merge($a, $b)
      notice(inline_template('merge[one]   is <%= @o["one"].inspect %>'))
      notice(inline_template('merge[two]   is <%= @o["two"].inspect %>'))
      notice(inline_template('merge[three] is <%= @o["three"].inspect %>'))
    DOC
    regex_array = [%r{merge\[one\]   is ("1"|1)}, %r{merge\[two\]   is "dos"}, %r{merge\[three\] is {"five"=>("5"|5)}}]
    it 'merges two hashes' do
      apply_manifest(pp, :catch_failures => true) do |r|
        regex_array.each do |i|
          expect(r.stdout).to match(i)
        end
      end
    end
  end
end
