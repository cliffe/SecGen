#! /usr/bin/env ruby -S rspec # rubocop:disable Lint/ScriptPermission : Rubocop Mistake???
require 'spec_helper_acceptance'

describe 'fqdn_rand_string function' do
  describe 'success' do
    include_context 'with faked facts'
    context "when the FQDN is 'fakehost.localdomain'" do
      before :each do
        fake_fact('fqdn', 'fakehost.localdomain')
      end

      pp1 = <<-PUPPETCODE
        $l = 10
        $o = fqdn_rand_string($l)
        notice(inline_template('fqdn_rand_string is <%= @o.inspect %>'))
      PUPPETCODE
      it 'generates random alphanumeric strings' do
        apply_manifest(pp1, :catch_failures => true) do |r|
          expect(r.stdout).to match(%r{fqdn_rand_string is "(7oDp0KOr1b|9Acvnhkt4J)"})
        end
      end

      pp2 = <<-PUPPETCODE
        $l = 10
        $c = '0123456789'
        $o = fqdn_rand_string($l, $c)
        notice(inline_template('fqdn_rand_string is <%= @o.inspect %>'))
      PUPPETCODE
      it 'generates random alphanumeric strings with custom charsets' do
        apply_manifest(pp2, :catch_failures => true) do |r|
          expect(r.stdout).to match(%r{fqdn_rand_string is "(7203048515|2383756694)"})
        end
      end

      pp3 = <<-PUPPETCODE
        $l = 10
        $s = 'seed'
        $o = fqdn_rand_string($l, undef, $s)
        notice(inline_template('fqdn_rand_string is <%= @o.inspect %>'))
      PUPPETCODE
      it 'generates random alphanumeric strings with custom seeds' do
        apply_manifest(pp3, :catch_failures => true) do |r|
          expect(r.stdout).to match(%r{fqdn_rand_string is "(3HS4mbuI3E|1jJtAMs94d)"})
        end
      end

      pp4 = <<-PUPPETCODE
        $l = 10
        $c = '0123456789'
        $s = 'seed'
        $o = fqdn_rand_string($l, $c, $s)
        notice(inline_template('fqdn_rand_string is <%= @o.inspect %>'))
      PUPPETCODE
      it 'generates random alphanumeric strings with custom charsets and seeds' do
        apply_manifest(pp4, :catch_failures => true) do |r|
          expect(r.stdout).to match(%r{fqdn_rand_string is "(3104058232|7100592312)"})
        end
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-numbers for length argument'
  end
end
