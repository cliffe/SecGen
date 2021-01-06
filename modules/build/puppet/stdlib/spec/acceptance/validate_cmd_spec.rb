#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'validate_cmd function' do
  describe 'success' do
    pp1 = <<-DOC
      $one = 'foo'
      if $::osfamily == 'windows' {
        $two = 'echo' #shell built-in
      } else {
        $two = '/bin/echo'
      }
      validate_cmd($one,$two)
    DOC
    it 'validates a true command' do
      apply_manifest(pp1, :catch_failures => true)
    end

    pp2 = <<-DOC
      $one = 'foo'
      if $::osfamily == 'windows' {
        $two = 'C:/aoeu'
      } else {
        $two = '/bin/aoeu'
      }
      validate_cmd($one,$two)
    DOC
    it 'validates a fail command' do
      apply_manifest(pp2, :expect_failures => true)
    end

    pp3 = <<-DOC
      $one = 'foo'
      if $::osfamily == 'windows' {
        $two = 'C:/aoeu'
      } else {
        $two = '/bin/aoeu'
      }
      validate_cmd($one,$two,"aoeu is dvorak")
    DOC
    it 'validates a fail command with a custom error message' do
      apply_manifest(pp3, :expect_failures => true) do |output|
        expect(output.stderr).to match(%r{aoeu is dvorak})
      end
    end
  end
  describe 'failure' do
    it 'handles improper number of arguments'
    it 'handles improper argument types'
  end
end
