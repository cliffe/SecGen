#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

tmpdir = default.tmpdir('stdlib')

describe 'loadjson function' do
  describe 'success' do
    it 'loadjsons array of values' do
      shell("echo '{\"aaa\":1,\"bbb\":2,\"ccc\":3,\"ddd\":4}' > #{tmpdir}/testjson.json")
      pp = <<-EOS
      $o = loadjson('#{tmpdir}/testjson.json')
      notice(inline_template('loadjson[aaa] is <%= @o["aaa"].inspect %>'))
      notice(inline_template('loadjson[bbb] is <%= @o["bbb"].inspect %>'))
      notice(inline_template('loadjson[ccc] is <%= @o["ccc"].inspect %>'))
      notice(inline_template('loadjson[ddd] is <%= @o["ddd"].inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/loadjson\[aaa\] is 1/)
        expect(r.stdout).to match(/loadjson\[bbb\] is 2/)
        expect(r.stdout).to match(/loadjson\[ccc\] is 3/)
        expect(r.stdout).to match(/loadjson\[ddd\] is 4/)
      end
    end

    it 'returns the default value if there is no file to load' do
      pp = <<-EOS
      $o = loadjson('#{tmpdir}/no-file.json', {'default' => 'value'})
      notice(inline_template('loadjson[default] is <%= @o["default"].inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/loadjson\[default\] is "value"/)
      end
    end

    it 'returns the default value if the file was parsed with an error' do
      shell("echo '!' > #{tmpdir}/testjson.json")
      pp = <<-EOS
      $o = loadjson('#{tmpdir}/testjson.json', {'default' => 'value'})
      notice(inline_template('loadjson[default] is <%= @o["default"].inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/loadjson\[default\] is "value"/)
      end
    end
  end
  describe 'failure' do
    it 'fails with no arguments'
  end
end
