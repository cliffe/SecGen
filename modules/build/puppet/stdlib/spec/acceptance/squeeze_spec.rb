#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'squeeze function' do
  describe 'success' do
    pp1 = <<-DOC
      # Real words!
      $a = ["wallless", "laparohysterosalpingooophorectomy", "brrr", "goddessship"]
      $o = squeeze($a)
      notice(inline_template('squeeze is <%= @o.inspect %>'))
    DOC
    it 'squeezes arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{squeeze is \["wales", "laparohysterosalpingophorectomy", "br", "godeship"\]})
      end
    end

    it 'squeezez arrays with an argument'
    pp2 = <<-DOC
      $a = "wallless laparohysterosalpingooophorectomy brrr goddessship"
      $o = squeeze($a)
      notice(inline_template('squeeze is <%= @o.inspect %>'))
    DOC
    it 'squeezes strings' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{squeeze is "wales laparohysterosalpingophorectomy br godeship"})
      end
    end

    pp3 = <<-DOC
      $a = "countessship duchessship governessship hostessship"
      $o = squeeze($a, 's')
      notice(inline_template('squeeze is <%= @o.inspect %>'))
    DOC
    it 'squeezes strings with an argument' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{squeeze is "counteship ducheship governeship hosteship"})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings or arrays'
  end
end
