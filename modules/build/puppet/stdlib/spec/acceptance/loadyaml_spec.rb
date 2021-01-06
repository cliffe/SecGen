#! /usr/bin/env ruby -S rspec # rubocop:disable Lint/ScriptPermission : Rubocop Error
require 'spec_helper_acceptance'

tmpdir = default.tmpdir('stdlib')

describe 'loadyaml function' do
  describe 'success' do
    shell("echo '---
      aaa: 1
      bbb: 2
      ccc: 3
      ddd: 4' > #{tmpdir}/test1yaml.yaml")
    pp1 = <<-DOC
      $o = loadyaml('#{tmpdir}/test1yaml.yaml')
      notice(inline_template('loadyaml[aaa] is <%= @o["aaa"].inspect %>'))
      notice(inline_template('loadyaml[bbb] is <%= @o["bbb"].inspect %>'))
      notice(inline_template('loadyaml[ccc] is <%= @o["ccc"].inspect %>'))
      notice(inline_template('loadyaml[ddd] is <%= @o["ddd"].inspect %>'))
    DOC
    regex_array = [%r{loadyaml\[aaa\] is 1}, %r{loadyaml\[bbb\] is 2}, %r{loadyaml\[ccc\] is 3}, %r{loadyaml\[ddd\] is 4}]
    it 'loadyamls array of values' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        regex_array.each do |i|
          expect(r.stdout).to match(i)
        end
      end
    end

    pp2 = <<-DOC
      $o = loadyaml('#{tmpdir}/no-file.yaml', {'default' => 'value'})
      notice(inline_template('loadyaml[default] is <%= @o["default"].inspect %>'))
    DOC
    it 'returns the default value if there is no file to load' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{loadyaml\[default\] is "value"})
      end
    end

    shell("echo '!' > #{tmpdir}/test2yaml.yaml")
    pp3 = <<-DOC
      $o = loadyaml('#{tmpdir}/test2yaml.yaml', {'default' => 'value'})
      notice(inline_template('loadyaml[default] is <%= @o["default"].inspect %>'))
    DOC
    it 'returns the default value if the file was parsed with an error' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{loadyaml\[default\] is "value"})
      end
    end
  end
  describe 'failure' do
    it 'fails with no arguments'
  end
end
