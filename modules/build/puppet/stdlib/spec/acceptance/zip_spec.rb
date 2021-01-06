#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'zip function' do
  describe 'success' do
    pp1 = <<-DOC
      $one = [1,2,3,4]
      $two = [5,6,7,8]
      $output = zip($one,$two)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'zips two arrays of numbers together' do
      expect(apply_manifest(pp1, :catch_failures => true).stdout).to match(%r{\[\[1, 5\], \[2, 6\], \[3, 7\], \[4, 8\]\]})
    end

    pp2 = <<-DOC
      $one = [1,2,"three",4]
      $two = [true,true,false,false]
      $output = zip($one,$two)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'zips two arrays of numbers & bools together' do
      expect(apply_manifest(pp2, :catch_failures => true).stdout).to match(%r{\[\[1, true\], \[2, true\], \["three", false\], \[4, false\]\]})
    end

    # XXX This only tests the argument `true`, even though the following are valid:
    # 1 t y true yes
    # 0 f n false no
    # undef undefined
    pp3 = <<-DOC
      $one = [1,2,3,4]
      $two = [5,6,7,8]
      $output = zip($one,$two,true)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'zips two arrays of numbers together and flattens them' do
      expect(apply_manifest(pp3, :catch_failures => true).stdout).to match(%r{\[1, 5, 2, 6, 3, 7, 4, 8\]})
    end

    # XXX Is this expected behavior?
    pp4 = <<-DOC
      $one = [1,2]
      $two = [5,6,7,8]
      $output = zip($one,$two)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'handles unmatched length' do
      expect(apply_manifest(pp4, :catch_failures => true).stdout).to match(%r{\[\[1, 5\], \[2, 6\]\]})
    end
  end

  describe 'failure' do
    pp5 = <<-DOC
      $one = [1,2]
      $output = zip($one)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'handles improper number of arguments' do
      expect(apply_manifest(pp5, :expect_failures => true).stderr).to match(%r{Wrong number of arguments})
    end

    pp6 = <<-DOC
      $one = "a string"
      $two = [5,6,7,8]
      $output = zip($one,$two)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'handles improper argument types' do
      expect(apply_manifest(pp6, :expect_failures => true).stderr).to match(%r{Requires array})
    end
  end
end
