#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'tempfile'
describe Puppet::Type.type(:file_line) do
  let :tmp_path do
    if Puppet::Util::Platform.windows?
      'C:\tmp\path'
    else
      '/tmp/path'
    end
  end
  let :my_path do
    if Puppet::Util::Platform.windows?
      'C:\my\path'
    else
      '/my/path'
    end
  end
  let :file_line do
    Puppet::Type.type(:file_line).new(:name => 'foo', :line => 'line', :path => tmp_path)
  end

  it 'accepts a line' do
    file_line[:line] = 'my_line'
    expect(file_line[:line]).to eq('my_line')
  end
  it 'accepts a path' do
    file_line[:path] = my_path
    expect(file_line[:path]).to eq(my_path)
  end
  it 'accepts a match regex' do
    file_line[:match] = '^foo.*$'
    expect(file_line[:match]).to eq('^foo.*$')
  end

  it 'accepts a match regex that does not match the specified line' do
    expect {
      Puppet::Type.type(:file_line).new(
        :name => 'foo', :path => my_path, :line => 'foo=bar', :match => '^bar=blah$',
      )
    }.not_to raise_error
  end
  it 'accepts a match regex that does match the specified line' do
    expect {
      Puppet::Type.type(:file_line).new(
        :name => 'foo', :path => my_path, :line => 'foo=bar', :match => '^\s*foo=.*$',
      )
    }.not_to raise_error
  end
  it 'accepts utf8 characters' do
    expect {
      Puppet::Type.type(:file_line).new(
        :name => 'ƒồỗ', :path => my_path, :line => 'ƒồỗ=ьåя', :match => '^ьåя=βļάħ$',
      )
    }.not_to raise_error
  end
  it 'accepts double byte characters' do
    expect {
      Puppet::Type.type(:file_line).new(
        :name => 'フーバー', :path => my_path, :line => 'この=それ', :match => '^この=ああ$',
      )
    }.not_to raise_error
  end
  it 'accepts posix filenames' do
    file_line[:path] = tmp_path
    expect(file_line[:path]).to eq(tmp_path)
  end
  it 'does not accept unqualified path' do
    expect { file_line[:path] = 'file' }.to raise_error(Puppet::Error, %r{File paths must be fully qualified})
  end
  it 'requires that a line is specified' do
    expect { Puppet::Type.type(:file_line).new(:name => 'foo', :path => tmp_path) }.to raise_error(Puppet::Error, %r{line is a required attribute})
  end
  it 'does not require that a line is specified when matching for absence' do
    expect { Puppet::Type.type(:file_line).new(:name => 'foo', :path => tmp_path, :ensure => :absent, :match_for_absence => :true, :match => 'match') }.not_to raise_error # rubocop:disable Lint/BooleanSymbol, Metrics/LineLength
  end
  it 'although if a line is specified anyway when matching for absence it still works and the line is silently ignored' do
    expect { Puppet::Type.type(:file_line).new(:name => 'foo', :path => tmp_path, :line => 'i_am_irrelevant', :ensure => :absent, :match_for_absence => :true, :match => 'match') }.not_to raise_error # rubocop:disable Lint/BooleanSymbol, Metrics/LineLength
  end
  it 'requires that a file is specified' do
    expect { Puppet::Type.type(:file_line).new(:name => 'foo', :line => 'path') }.to raise_error(Puppet::Error, %r{path is a required attribute})
  end
  it 'defaults to ensure => present' do
    expect(file_line[:ensure]).to eq :present
  end
  it 'defaults to replace => true' do
    expect(file_line[:replace]).to eq :true # rubocop:disable Lint/BooleanSymbol
  end
  it 'defaults to encoding => UTF-8' do
    expect(file_line[:encoding]).to eq 'UTF-8'
  end
  it 'accepts encoding => iso-8859-1' do
    expect { Puppet::Type.type(:file_line).new(:name => 'foo', :path => tmp_path, :ensure => :present, :encoding => 'iso-8859-1', :line => 'bar') }.not_to raise_error
  end

  it 'autorequires the file it manages' do # rubocop:disable RSpec/ExampleLength : example size cannot be reduced
    catalog = Puppet::Resource::Catalog.new
    file = Puppet::Type.type(:file).new(:name => tmp_path)
    catalog.add_resource file
    catalog.add_resource file_line
    relationship = file_line.autorequire.find do |rel|
      (rel.source.to_s == "File[#{tmp_path}]") && (rel.target.to_s == file_line.to_s)
    end
    expect(relationship).to be_a Puppet::Relationship
  end

  it 'does not autorequire the file it manages if it is not managed' do
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource file_line
    expect(file_line.autorequire).to be_empty
  end
end
