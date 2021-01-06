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

  describe '#create' do
    context 'when adding' do
      pending('To be added.')
    end
    context 'when replacing' do
      let :params do
        {
          :line => 'foo = bar',
          :match => '^foo\s*=.*$',
          :replace => false,
        }
      end
      let(:content) { "foo1\nfoo=blah\nfoo2\nfoo3" }

      it "providor 'be_exists'" do
        expect(provider).to be_exists
      end
      it 'does not replace the matching line' do
        provider.create
        expect(File.read(tmpfile).chomp).to eql("foo1\nfoo=blah\nfoo2\nfoo3")
      end
      it 'appends the line if no matches are found' do # rubocop:disable RSpec/MultipleExpectations : separating expectations breaks the tests
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo2") }
        expect(provider.exists?).to be false
        provider.create
        expect(File.read(tmpfile).chomp).to eql("foo1\nfoo2\nfoo = bar")
      end
      it 'raises an error with invalid values' do
        expect {
          @resource = Puppet::Type::File_line.new(
            :name => 'foo', :path => tmpfile, :line => 'foo = bar', :match => '^foo\s*=.*$', :replace => 'asgadga',
          )
        }.to raise_error(Puppet::Error, %r{Invalid value "asgadga"\. Valid values are true, false\.})
      end
    end
  end
  describe '#destroy' do
    pending('To be added?')
  end
  context 'when matching' do
    # rubocop:disable RSpec/InstanceVariable : replacing before with let breaks the tests, variables need to be altered within it block : multi
    before :each do
      @resource = Puppet::Type::File_line.new(
        :name => 'foo',
        :path => tmpfile,
        :line => 'foo = bar',
        :match => '^foo\s*=.*$',
      )
      @provider = provider_class.new(@resource)
    end
    describe 'using match' do
      it 'raises an error if more than one line matches, and should not have modified the file' do # rubocop:disable RSpec/MultipleExpectations : multiple expectations required
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo=blah\nfoo2\nfoo=baz") }
        expect { @provider.create }.to raise_error(Puppet::Error, %r{More than one line.*matches})
        expect(File.read(tmpfile)).to eql("foo1\nfoo=blah\nfoo2\nfoo=baz")
      end

      it 'replaces all lines that matches' do
        @resource = Puppet::Type::File_line.new(:name => 'foo', :path => tmpfile, :line => 'foo = bar', :match => '^foo\s*=.*$', :multiple => true)
        @provider = provider_class.new(@resource)
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo=blah\nfoo2\nfoo=baz") }
        @provider.create
        expect(File.read(tmpfile).chomp).to eql("foo1\nfoo = bar\nfoo2\nfoo = bar")
      end

      it 'replaces all lines that match, even when some lines are correct' do
        @resource = Puppet::Type::File_line.new(:name => 'neil', :path => tmpfile, :line => "\thard\tcore\t0\n", :match => '^[ \t]hard[ \t]+core[ \t]+.*', :multiple => true)
        @provider = provider_class.new(@resource)
        File.open(tmpfile, 'w') { |fh| fh.write("\thard\tcore\t90\n\thard\tcore\t0\n") }
        @provider.create
        expect(File.read(tmpfile).chomp).to eql("\thard\tcore\t0\n\thard\tcore\t0")
      end

      it 'raises an error with invalid values' do
        expect {
          @resource = Puppet::Type::File_line.new(
            :name => 'foo', :path => tmpfile, :line => 'foo = bar', :match => '^foo\s*=.*$', :multiple => 'asgadga',
          )
        }.to raise_error(Puppet::Error, %r{Invalid value "asgadga"\. Valid values are true, false\.})
      end

      it 'replaces a line that matches' do
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo=blah\nfoo2") }
        @provider.create
        expect(File.read(tmpfile).chomp).to eql("foo1\nfoo = bar\nfoo2")
      end
      it 'adds a new line if no lines match' do
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo2") }
        @provider.create
        expect(File.read(tmpfile)).to eql("foo1\nfoo2\nfoo = bar\n")
      end
      it 'does nothing if the exact line already exists' do
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo = bar\nfoo2") }
        @provider.create
        expect(File.read(tmpfile).chomp).to eql("foo1\nfoo = bar\nfoo2")
      end
    end
    describe 'using match+append_on_no_match - when there is a match' do
      it 'replaces line' do
        @resource = Puppet::Type::File_line.new(:name => 'foo', :path => tmpfile, :line => 'inserted = line', :match => '^foo3$', :append_on_no_match => false)
        @provider = provider_class.new(@resource)
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo = blah\nfoo2\nfoo = baz") }
        expect(File.read(tmpfile).chomp).to eql("foo1\nfoo = blah\nfoo2\nfoo = baz")
      end
    end
    describe 'using match+append_on_no_match - when there is no match' do
      it 'does not add line after no matches found' do
        @resource = Puppet::Type::File_line.new(:name => 'foo', :path => tmpfile, :line => 'inserted = line', :match => '^foo3$', :append_on_no_match => false)
        @provider = provider_class.new(@resource)
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo = blah\nfoo2\nfoo = baz") }
        expect(File.read(tmpfile).chomp).to eql("foo1\nfoo = blah\nfoo2\nfoo = baz")
      end
    end
  end
  context 'when match+replace+append_on_no_match' do
    pending('to do')
  end
  context 'when after' do
    let :resource do
      Puppet::Type::File_line.new(
        :name => 'foo',
        :path => tmpfile,
        :line => 'inserted = line',
        :after => '^foo1',
      )
    end

    let :provider do
      provider_class.new(resource)
    end

    context 'when match and after set' do
      shared_context 'when resource_create' do
        let(:match) { '^foo2$' }
        let(:after) { '^foo1$' }
        let(:resource) do
          Puppet::Type::File_line.new(
            :name => 'foo',
            :path => tmpfile,
            :line => 'inserted = line',
            :after => after,
            :match => match,
          )
        end
      end
      before :each do
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo2\nfoo = baz") }
      end
      # rubocop:disable RSpec/NestedGroups : Reducing the nesting would needlesly complicate the code
      describe 'inserts at match' do
        include_context 'resource_create'
        it {
          provider.create
          expect(File.read(tmpfile).chomp).to eq("foo1\ninserted = line\nfoo = baz")
        }
      end
      describe 'inserts a new line after when no match' do
        include_context 'resource_create' do
          let(:match) { '^nevergoingtomatch$' }
        end
        it {
          provider.create
          expect(File.read(tmpfile).chomp).to eq("foo1\ninserted = line\nfoo2\nfoo = baz")
        }
      end
      describe 'append to end of file if no match for both after and match' do
        include_context 'resource_create' do
          let(:match) { '^nevergoingtomatch$' }
          let(:after) { '^stillneverafter' }
        end
        it {
          provider.create
          expect(File.read(tmpfile).chomp).to eq("foo1\nfoo2\nfoo = baz\ninserted = line")
        }
      end
    end
    context 'with one line matching the after expression' do
      before :each do
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo = blah\nfoo2\nfoo = baz") }
      end

      it 'inserts the specified line after the line matching the "after" expression' do
        provider.create
        expect(File.read(tmpfile).chomp).to eql("foo1\ninserted = line\nfoo = blah\nfoo2\nfoo = baz")
      end
    end
    context 'with multiple lines matching the after expression' do
      before :each do
        File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo = blah\nfoo2\nfoo1\nfoo = baz") }
      end

      it 'errors out stating "One or no line must match the pattern"' do
        expect { provider.create }.to raise_error(Puppet::Error, %r{One or no line must match the pattern})
      end

      it 'adds the line after all lines matching the after expression' do
        @resource = Puppet::Type::File_line.new(:name => 'foo', :path => tmpfile, :line => 'inserted = line', :after => '^foo1$', :multiple => true)
        @provider = provider_class.new(@resource)
        @provider.create
        expect(File.read(tmpfile).chomp).to eql("foo1\ninserted = line\nfoo = blah\nfoo2\nfoo1\ninserted = line\nfoo = baz")
      end
    end
    context 'with no lines matching the after expression' do
      let :content do
        "foo3\nfoo = blah\nfoo2\nfoo = baz\n"
      end

      before :each do
        File.open(tmpfile, 'w') { |fh| fh.write(content) }
      end

      it 'appends the specified line to the file' do
        provider.create
        expect(File.read(tmpfile)).to eq(content << resource[:line] << "\n")
      end
    end
  end
  context 'when removing with a line' do
    before :each do
      # TODO: these should be ported over to use the PuppetLabs spec_helper
      #  file fixtures once the following pull request has been merged:
      # https://github.com/puppetlabs/puppetlabs-stdlib/pull/73/files
      @resource = Puppet::Type::File_line.new(
        :name => 'foo',
        :path => tmpfile,
        :line => 'foo',
        :ensure => 'absent',
      )
      @provider = provider_class.new(@resource)
    end
    it 'removes the line if it exists' do
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2")
    end
    it 'removes the line without touching the last new line' do
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2\n") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2\n")
    end
    it 'removes any occurence of the line' do
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2\nfoo\nfoo") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2\n")
    end
    it 'example in the docs' do
      @resource = Puppet::Type::File_line.new(:name => 'bashrc_proxy', :ensure => 'absent', :path => tmpfile, :line => 'export HTTP_PROXY=http://squid.puppetlabs.vm:3128')
      @provider = provider_class.new(@resource)
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo2\nexport HTTP_PROXY=http://squid.puppetlabs.vm:3128\nfoo4\n") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2\nfoo4\n")
    end
  end
  context 'when removing with a match' do
    before :each do
      @resource = Puppet::Type::File_line.new(
        :name => 'foo',
        :path => tmpfile,
        :line => 'foo2',
        :ensure => 'absent',
        :match => 'o$',
        :match_for_absence => true,
      )
      @provider = provider_class.new(@resource)
    end

    it 'finds a line to match' do
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2") }
      expect(@provider.exists?).to be true
    end

    it 'removes one line if it matches' do
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2")
    end

    it 'the line parameter is actually not used at all but is silently ignored if here' do
      @resource = Puppet::Type::File_line.new(:name => 'foo', :path => tmpfile, :line => 'supercalifragilisticexpialidocious', :ensure => 'absent', :match => 'o$', :match_for_absence => true)
      @provider = provider_class.new(@resource)
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2")
    end

    it 'and may not be here and does not need to be here' do
      @resource = Puppet::Type::File_line.new(:name => 'foo', :path => tmpfile, :ensure => 'absent', :match => 'o$', :match_for_absence => true)
      @provider = provider_class.new(@resource)
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2")
    end

    it 'raises an error if more than one line matches' do
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2\nfoo\nfoo") }
      expect { @provider.destroy }.to raise_error(Puppet::Error, %r{More than one line})
    end

    it 'removes multiple lines if :multiple is true' do
      @resource = Puppet::Type::File_line.new(:name => 'foo', :path => tmpfile, :line => 'foo2', :ensure => 'absent', :match => 'o$', :multiple => true, :match_for_absence => true)
      @provider = provider_class.new(@resource)
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2\nfoo\nfoo") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2\n")
    end

    it 'ignores the match if match_for_absence is not specified' do
      @resource = Puppet::Type::File_line.new(:name => 'foo', :path => tmpfile, :line => 'foo2', :ensure => 'absent', :match => 'o$')
      @provider = provider_class.new(@resource)
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo\n")
    end

    it 'ignores the match if match_for_absence is false' do
      @resource = Puppet::Type::File_line.new(:name => 'foo', :path => tmpfile, :line => 'foo2', :ensure => 'absent', :match => 'o$', :match_for_absence => false)
      @provider = provider_class.new(@resource)
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo\nfoo2") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo\n")
    end

    it 'example in the docs' do # rubocop:disable RSpec/ExampleLength : Cannot reduce without violating line length rule
      @resource = Puppet::Type::File_line.new(
        :name => 'bashrc_proxy', :ensure => 'absent', :path => tmpfile, :line => 'export HTTP_PROXY=http://squid.puppetlabs.vm:3128',
        :match => '^export\ HTTP_PROXY\=', :match_for_absence => true
      )
      @provider = provider_class.new(@resource)
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo2\nexport HTTP_PROXY=foo\nfoo4\n") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2\nfoo4\n")
    end

    it 'example in the docs showing line is redundant' do
      @resource = Puppet::Type::File_line.new(:name => 'bashrc_proxy', :ensure => 'absent', :path => tmpfile, :match => '^export\ HTTP_PROXY\=', :match_for_absence => true)
      @provider = provider_class.new(@resource)
      File.open(tmpfile, 'w') { |fh| fh.write("foo1\nfoo2\nexport HTTP_PROXY=foo\nfoo4\n") }
      @provider.destroy
      expect(File.read(tmpfile)).to eql("foo1\nfoo2\nfoo4\n")
    end
  end
  # rubocop:enable RSpec/InstanceVariable : multi
end
