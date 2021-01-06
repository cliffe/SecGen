#! /usr/bin/env ruby -S rspec
require 'spec_helper'

provider_class = Puppet::Type.type(:file_line).provider(:ruby)
#  These tests fail on windows when run as part of the rake task. Individually they pass
describe provider_class, :unless => Puppet::Util::Platform.windows? do
  include PuppetlabsSpec::Files

  let :tmpfile do
    tmpfilename('file_line_test')
  end
  let :content do
    ''
  end
  let :params do
    {}
  end
  let :resource do
    Puppet::Type::File_line.new({
      :name => 'foo',
      :path => tmpfile,
      :line => 'foo',
    }.merge(params))
  end
  let :provider do
    provider_class.new(resource)
  end

  before :each do
    File.open(tmpfile, 'w') do |fh|
      fh.write(content)
    end
  end

  describe 'line parameter' do
    context 'when line exists' do
      let(:content) { 'foo' }

      it 'detects the line' do
        expect(provider).to be_exists
      end
    end
    context 'when line does not exist' do
      let(:content) { 'foo bar' }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'appends the line' do
        provider.create
        expect(File.read(tmpfile).chomp).to eq("foo bar\nfoo")
      end
    end
  end

  describe 'match parameter' do
    let(:params) { { :match => '^bar' } }

    describe 'does not match line - line does not exist - replacing' do
      let(:content) { "foo bar\nbar" }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'replaces the match' do
        provider.create
        expect(File.read(tmpfile).chomp).to eq("foo bar\nfoo")
      end
    end

    describe 'does not match line - line does not exist - appending' do
      let(:params) { super().merge(:replace => false) }
      let(:content) { "foo bar\nbar" }

      it 'does not request changes' do
        expect(provider).to be_exists
      end
    end

    context 'when does not match line - line exists' do
      let(:content) { "foo\nbar" }

      it 'detects the line' do
        expect(provider).to be_exists
      end
    end

    context 'when matches line - line exists' do
      let(:params) { { :match => '^foo' } }
      let(:content) { "foo\nbar" }

      it 'detects the line' do
        expect(provider).to be_exists
      end
    end

    context 'when matches line - line does not exist' do
      let(:params) { { :match => '^foo' } }
      let(:content) { "foo bar\nbar" }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'replaces the match' do
        provider.create
        expect(File.read(tmpfile).chomp).to eq("foo\nbar")
      end
    end
  end

  describe 'append_on_no_match' do
    let(:params) do
      {
        :append_on_no_match => false,
        :match => '^foo1$',
      }
    end

    context 'when matching' do
      let(:content) { "foo1\nbar" }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'replaces the match' do
        provider.create
        expect(File.read(tmpfile).chomp).to eql("foo\nbar")
      end
    end
    context 'when not matching' do
      let(:content) { "foo3\nbar" }

      it 'does not affect the file' do
        expect(provider).to be_exists
      end
    end
  end

  describe 'replace_all_matches_not_matching_line' do
    context 'when replace is false' do
      let(:params) do
        {
          :replace_all_matches_not_matching_line => true,
          :replace => false,
        }
      end

      it 'raises an error' do
        expect { provider.exists? }.to raise_error(Puppet::Error, %r{replace must be true})
      end
    end

    context 'when match matches line - when there are more matches than lines' do
      let(:params) do
        {
          :replace_all_matches_not_matching_line => true,
          :match => '^foo',
          :multiple => true,
        }
      end
      let(:content) { "foo\nfoo bar\nbar\nfoo baz" }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'replaces the matches' do
        provider.create
        expect(File.read(tmpfile).chomp).to eql("foo\nfoo\nbar\nfoo")
      end
    end

    context 'when match matches line - when there are the same matches and lines' do
      let(:params) do
        {
          :replace_all_matches_not_matching_line => true,
          :match => '^foo',
          :multiple => true,
        }
      end
      let(:content) { "foo\nfoo\nbar" }

      it 'does not request changes' do
        expect(provider).to be_exists
      end
    end

    context 'when match does not match line - when there are more matches than lines' do
      let(:params) do
        {
          :replace_all_matches_not_matching_line => true,
          :match => '^bar',
          :multiple => true,
        }
      end
      let(:content) { "foo\nfoo bar\nbar\nbar baz" }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'replaces the matches' do
        provider.create
        expect(File.read(tmpfile).chomp).to eql("foo\nfoo bar\nfoo\nfoo")
      end
    end

    context 'when match does not match line - when there are the same matches and lines' do
      let(:params) do
        {
          :replace_all_matches_not_matching_line => true,
          :match => '^bar',
          :multiple => true,
        }
      end
      let(:content) { "foo\nfoo\nbar\nbar baz" }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'replaces the matches' do
        provider.create
        expect(File.read(tmpfile).chomp).to eql("foo\nfoo\nfoo\nfoo")
      end
    end
  end

  context 'when match does not match line - when there are no matches' do
    let(:params) do
      {
        :replace_all_matches_not_matching_line => true,
        :match => '^bar',
        :multiple => true,
      }
    end
    let(:content) { "foo\nfoo bar" }

    it 'does not request changes' do
      expect(provider).to be_exists
    end
  end

  context 'when match does not match line - when there are no matches or lines' do
    let(:params) do
      {
        :replace_all_matches_not_matching_line => true,
        :match => '^bar',
        :multiple => true,
      }
    end
    let(:content) { 'foo bar' }

    it 'requests changes' do
      expect(provider).not_to be_exists
    end
    it 'appends the line' do
      provider.create
      expect(File.read(tmpfile).chomp).to eql("foo bar\nfoo")
    end
  end
end
