#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'unique function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = ["wallless", "wallless", "brrr", "goddessship"]
      $o = unique($a)
      notice(inline_template('unique is <%= @o.inspect %>'))
    DOC
    it 'uniques arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{unique is \["wallless", "brrr", "goddessship"\]})
      end
    end

    pp2 = <<-DOC
      $a = "wallless laparohysterosalpingooophorectomy brrr goddessship"
      $o = unique($a)
      notice(inline_template('unique is <%= @o.inspect %>'))
    DOC
    it 'uniques strings' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{unique is "wales prohytingcmbd"})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings or arrays'
  end
end
