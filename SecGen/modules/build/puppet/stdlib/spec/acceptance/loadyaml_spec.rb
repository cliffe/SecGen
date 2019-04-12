#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

tmpdir = default.tmpdir('stdlib')

describe 'loadyaml function' do
  describe 'success' do
    it 'loadyamls array of values' do
      shell("echo '---
      aaa: 1
      bbb: 2
      ccc: 3
      ddd: 4' > #{tmpdir}/testyaml.yaml")
      pp = <<-EOS
      $o = loadyaml('#{tmpdir}/testyaml.yaml')
      notice(inline_template('loadyaml[aaa] is <%= @o["aaa"].inspect %>'))
      notice(inline_template('loadyaml[bbb] is <%= @o["bbb"].inspect %>'))
      notice(inline_template('loadyaml[ccc] is <%= @o["ccc"].inspect %>'))
      notice(inline_template('loadyaml[ddd] is <%= @o["ddd"].inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/loadyaml\[aaa\] is 1/)
        expect(r.stdout).to match(/loadyaml\[bbb\] is 2/)
        expect(r.stdout).to match(/loadyaml\[ccc\] is 3/)
        expect(r.stdout).to match(/loadyaml\[ddd\] is 4/)
      end
    end

    it 'returns the default value if there is no file to load' do
      pp = <<-EOS
      $o = loadyaml('#{tmpdir}/no-file.yaml', {'default' => 'value'})
      notice(inline_template('loadyaml[default] is <%= @o["default"].inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/loadyaml\[default\] is "value"/)
      end
    end

    it 'returns the default value if the file was parsed with an error' do
      shell("echo '!' > #{tmpdir}/testyaml.yaml")
      pp = <<-EOS
      $o = loadyaml('#{tmpdir}/testyaml.yaml', {'default' => 'value'})
      notice(inline_template('loadyaml[default] is <%= @o["default"].inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/loadyaml\[default\] is "value"/)
      end
    end
  end
  describe 'failure' do
    it 'fails with no arguments'
  end
end
