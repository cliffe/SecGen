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

  describe 'customer use cases - no lines' do
    describe 'MODULES-5003' do
      let(:params) do
        {
          :line => "*\thard\tcore\t0",
          :match => "^[ \t]*\\*[ \t]+hard[ \t]+core[ \t]+.*",
          :multiple => true,
        }
      end
      let(:content) { "*	hard	core	90\n*	hard	core	10\n" }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'replaces the matches' do
        provider.create
        expect(File.read(tmpfile).chomp).to eq("*	hard	core	0\n*	hard	core	0")
      end
    end

    describe 'MODULES-5003 - one match, one line - just ensure the line exists' do
      let(:params) do
        {
          :line => "*\thard\tcore\t0",
          :match => "^[ \t]*\\*[ \t]+hard[ \t]+core[ \t]+.*",
          :multiple => true,
        }
      end
      let(:content) { "*	hard	core	90\n*	hard	core	0\n" }

      it 'does not request changes' do
        expect(provider).to be_exists
      end
    end

    describe 'MODULES-5003 - one match, one line - replace all matches, even when line exists' do
      let(:params) do
        {
          :line => "*\thard\tcore\t0",
          :match => "^[ \t]*\\*[ \t]+hard[ \t]+core[ \t]+.*",
          :multiple => true,

        }.merge(:replace_all_matches_not_matching_line => true)
      end
      let(:content) { "*	hard	core	90\n*	hard	core	0\n" }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'replaces the matches' do
        provider.create
        expect(File.read(tmpfile).chomp).to eq("*	hard	core	0\n*	hard	core	0")
      end
    end

    describe 'MODULES-5651 - match, no line' do
      let(:params) do
        {
          :line => 'LogLevel=notice',
          :match => '^#LogLevel$',
        }
      end
      let(:content) { "#LogLevel\nstuff" }

      it 'requests changes' do
        expect(provider).not_to be_exists
      end
      it 'replaces the match' do
        provider.create
        expect(File.read(tmpfile).chomp).to eq("LogLevel=notice\nstuff")
      end
    end

    describe 'MODULES-5651 - match, line' do
      let(:params) do
        {
          :line => 'LogLevel=notice',
          :match => '^#LogLevel$',
        }
      end
      let(:content) { "#Loglevel\nLogLevel=notice\nstuff" }

      it 'does not request changes' do
        expect(provider).to be_exists
      end
    end

    describe 'MODULES-5651 - no match, line' do
      let(:params) do
        {
          :line => 'LogLevel=notice',
          :match => '^#LogLevel$',
        }
      end
      let(:content) { "LogLevel=notice\nstuff" }

      it 'does not request changes' do
        expect(provider).to be_exists
      end
    end
  end
end
