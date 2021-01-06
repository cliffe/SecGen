#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'upcase function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = ["wallless", "laparohysterosalpingooophorectomy", "brrr", "goddessship"]
      $o = upcase($a)
      notice(inline_template('upcase is <%= @o.inspect %>'))
    DOC
    it 'upcases arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{upcase is \["WALLLESS", "LAPAROHYSTEROSALPINGOOOPHORECTOMY", "BRRR", "GODDESSSHIP"\]})
      end
    end

    pp2 = <<-DOC
      $a = "wallless laparohysterosalpingooophorectomy brrr goddessship"
      $o = upcase($a)
      notice(inline_template('upcase is <%= @o.inspect %>'))
    DOC
    it 'upcases strings' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{upcase is "WALLLESS LAPAROHYSTEROSALPINGOOOPHORECTOMY BRRR GODDESSSHIP"})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings or arrays'
  end
end
