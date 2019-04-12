#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'tempfile'
provider_class = Puppet::Type.type(:file_line).provider(:ruby)
describe provider_class do
  context "when adding" do
    let :tmpfile do
      tmp = Tempfile.new('tmp')
      path = tmp.path
      tmp.close!
      path
    end
    let :resource do
      Puppet::Type::File_line.new(
        {:name => 'foo', :path => tmpfile, :line => 'foo'}
      )
    end
    let :provider do
      provider_class.new(resource)
    end

    it 'should detect if the line exists in the file' do
      File.open(tmpfile, 'w') do |fh|
        fh.write('foo')
      end
      expect(provider.exists?).to be_truthy
    end
    it 'should detect if the line does not exist in the file' do
      File.open(tmpfile, 'w') do |fh|
        fh.write('foo1')
      end
      expect(provider.exists?).to be_nil
    end
    it 'should append to an existing file when creating' do
      provider.create
      expect(File.read(tmpfile).chomp).to eq('foo')
    end
  end
  context 'when using replace' do
    before :each do
      # TODO: these should be ported over to use the PuppetLabs spec_helper
      #  file fixtures once the following pull request has been merged:
      # https://github.com/puppetlabs/puppetlabs-stdlib/pull/73/files
      tmp = Tempfile.new('tmp')
      @tmpfile = tmp.path
      tmp.close!
      @resource = Puppet::Type::File_line.new(
        {
          :name    => 'foo',
          :path    => @tmpfile,
          :line    => 'foo = bar',
          :match   => '^foo\s*=.*$',
          :replace => false,
        }
      )
      @provider = provider_class.new(@resource)
    end

    it 'should not replace the matching line' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo=blah\nfoo2\nfoo3")
      end
      expect(@provider.exists?).to be_truthy
      @provider.create
      expect(File.read(@tmpfile).chomp).to eql("foo1\nfoo=blah\nfoo2\nfoo3")
    end

    it 'should append the line if no matches are found' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo2")
      end
      expect(@provider.exists?).to be_nil
      @provider.create
      expect(File.read(@tmpfile).chomp).to eql("foo1\nfoo2\nfoo = bar")
    end

    it 'should raise an error with invalid values' do
      expect {
        @resource = Puppet::Type::File_line.new(
          {
            :name     => 'foo',
            :path     => @tmpfile,
            :line     => 'foo = bar',
            :match    => '^foo\s*=.*$',
            :replace  => 'asgadga',
          }
        )
      }.to raise_error(Puppet::Error, /Invalid value "asgadga"\. Valid values are true, false\./)
    end
  end
  context "when matching" do
    before :each do
      # TODO: these should be ported over to use the PuppetLabs spec_helper
      #  file fixtures once the following pull request has been merged:
      # https://github.com/puppetlabs/puppetlabs-stdlib/pull/73/files
      tmp = Tempfile.new('tmp')
      @tmpfile = tmp.path
      tmp.close!
      @resource = Puppet::Type::File_line.new(
        {
          :name  => 'foo',
          :path  => @tmpfile,
          :line  => 'foo = bar',
          :match => '^foo\s*=.*$',
        }
      )
      @provider = provider_class.new(@resource)
    end

    describe 'using match' do
      it 'should raise an error if more than one line matches, and should not have modified the file' do
        File.open(@tmpfile, 'w') do |fh|
          fh.write("foo1\nfoo=blah\nfoo2\nfoo=baz")
        end
        expect(@provider.exists?).to be_nil
        expect { @provider.create }.to raise_error(Puppet::Error, /More than one line.*matches/)
        expect(File.read(@tmpfile)).to eql("foo1\nfoo=blah\nfoo2\nfoo=baz")
      end

      it 'should replace all lines that matches' do
        @resource = Puppet::Type::File_line.new(
          {
            :name     => 'foo',
            :path     => @tmpfile,
            :line     => 'foo = bar',
            :match    => '^foo\s*=.*$',
            :multiple => true,
          }
        )
        @provider = provider_class.new(@resource)
        File.open(@tmpfile, 'w') do |fh|
          fh.write("foo1\nfoo=blah\nfoo2\nfoo=baz")
        end
        expect(@provider.exists?).to be_nil
        @provider.create
        expect(File.read(@tmpfile).chomp).to eql("foo1\nfoo = bar\nfoo2\nfoo = bar")
      end

      it 'should raise an error with invalid values' do
        expect {
          @resource = Puppet::Type::File_line.new(
            {
              :name     => 'foo',
              :path     => @tmpfile,
              :line     => 'foo = bar',
              :match    => '^foo\s*=.*$',
              :multiple => 'asgadga',
            }
          )
        }.to raise_error(Puppet::Error, /Invalid value "asgadga"\. Valid values are true, false\./)
      end

      it 'should replace a line that matches' do
        File.open(@tmpfile, 'w') do |fh|
          fh.write("foo1\nfoo=blah\nfoo2")
        end
        expect(@provider.exists?).to be_nil
        @provider.create
        expect(File.read(@tmpfile).chomp).to eql("foo1\nfoo = bar\nfoo2")
      end
      it 'should add a new line if no lines match' do
        File.open(@tmpfile, 'w') do |fh|
          fh.write("foo1\nfoo2")
        end
        expect(@provider.exists?).to be_nil
        @provider.create
        expect(File.read(@tmpfile)).to eql("foo1\nfoo2\nfoo = bar\n")
      end
      it 'should do nothing if the exact line already exists' do
        File.open(@tmpfile, 'w') do |fh|
          fh.write("foo1\nfoo = bar\nfoo2")
        end
        expect(@provider.exists?).to be_truthy
        @provider.create
        expect(File.read(@tmpfile).chomp).to eql("foo1\nfoo = bar\nfoo2")
      end
    end

    describe 'using after' do
      let :resource do
        Puppet::Type::File_line.new(
          {
            :name  => 'foo',
            :path  => @tmpfile,
            :line  => 'inserted = line',
            :after => '^foo1',
          }
        )
      end

      let :provider do
        provider_class.new(resource)
      end
      context 'match and after set' do
        shared_context 'resource_create' do
          let(:match) { '^foo2$' }
          let(:after) { '^foo1$' }
          let(:resource) {
            Puppet::Type::File_line.new(
              {
                :name  => 'foo',
                :path  => @tmpfile,
                :line  => 'inserted = line',
                :after => after,
                :match => match,
              }
            )
          }
        end
        before :each do
          File.open(@tmpfile, 'w') do |fh|
            fh.write("foo1\nfoo2\nfoo = baz")
          end
        end
        describe 'inserts at match' do
          include_context 'resource_create'
          it {
            provider.create
            expect(File.read(@tmpfile).chomp).to eq("foo1\ninserted = line\nfoo = baz")
          }
        end
        describe 'inserts a new line after when no match' do
          include_context 'resource_create' do
            let(:match) { '^nevergoingtomatch$' }
          end
          it {
            provider.create
            expect(File.read(@tmpfile).chomp).to eq("foo1\ninserted = line\nfoo2\nfoo = baz")
          }
        end
        describe 'append to end of file if no match for both after and match' do
          include_context 'resource_create' do
            let(:match) { '^nevergoingtomatch$' }
            let(:after) { '^stillneverafter' }
          end
          it {
            provider.create
            expect(File.read(@tmpfile).chomp).to eq("foo1\nfoo2\nfoo = baz\ninserted = line")
          }
        end
      end
      context 'with one line matching the after expression' do
        before :each do
          File.open(@tmpfile, 'w') do |fh|
            fh.write("foo1\nfoo = blah\nfoo2\nfoo = baz")
          end
        end

        it 'inserts the specified line after the line matching the "after" expression' do
          provider.create
          expect(File.read(@tmpfile).chomp).to eql("foo1\ninserted = line\nfoo = blah\nfoo2\nfoo = baz")
        end
      end

      context 'with multiple lines matching the after expression' do
        before :each do
          File.open(@tmpfile, 'w') do |fh|
            fh.write("foo1\nfoo = blah\nfoo2\nfoo1\nfoo = baz")
          end
        end

        it 'errors out stating "One or no line must match the pattern"' do
          expect { provider.create }.to raise_error(Puppet::Error, /One or no line must match the pattern/)
        end

        it 'adds the line after all lines matching the after expression' do
          @resource = Puppet::Type::File_line.new(
            {
              :name     => 'foo',
              :path     => @tmpfile,
              :line     => 'inserted = line',
              :after    => '^foo1$',
              :multiple => true,
            }
          )
          @provider = provider_class.new(@resource)
          expect(@provider.exists?).to be_nil
          @provider.create
          expect(File.read(@tmpfile).chomp).to eql("foo1\ninserted = line\nfoo = blah\nfoo2\nfoo1\ninserted = line\nfoo = baz")
        end
      end

      context 'with no lines matching the after expression' do
        let :content do
          "foo3\nfoo = blah\nfoo2\nfoo = baz\n"
        end

        before :each do
          File.open(@tmpfile, 'w') do |fh|
            fh.write(content)
          end
        end

        it 'appends the specified line to the file' do
          provider.create
          expect(File.read(@tmpfile)).to eq(content << resource[:line] << "\n")
        end
      end
    end
  end

  context "when removing" do
    before :each do
      # TODO: these should be ported over to use the PuppetLabs spec_helper
      #  file fixtures once the following pull request has been merged:
      # https://github.com/puppetlabs/puppetlabs-stdlib/pull/73/files
      tmp = Tempfile.new('tmp')
      @tmpfile = tmp.path
      tmp.close!
      @resource = Puppet::Type::File_line.new(
        {
          :name   => 'foo',
          :path   => @tmpfile,
          :line   => 'foo',
          :ensure => 'absent',
        }
      )
      @provider = provider_class.new(@resource)
    end
    it 'should remove the line if it exists' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2")
      end
      @provider.destroy
      expect(File.read(@tmpfile)).to eql("foo1\nfoo2")
    end

    it 'should remove the line without touching the last new line' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2\n")
      end
      @provider.destroy
      expect(File.read(@tmpfile)).to eql("foo1\nfoo2\n")
    end

    it 'should remove any occurence of the line' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2\nfoo\nfoo")
      end
      @provider.destroy
      expect(File.read(@tmpfile)).to eql("foo1\nfoo2\n")
    end
  end

  context "when removing with a match" do
    before :each do
      # TODO: these should be ported over to use the PuppetLabs spec_helper
      #  file fixtures once the following pull request has been merged:
      # https://github.com/puppetlabs/puppetlabs-stdlib/pull/73/files
      tmp = Tempfile.new('tmp')
      @tmpfile = tmp.path
      tmp.close!
      @resource = Puppet::Type::File_line.new(
        {
          :name              => 'foo',
          :path              => @tmpfile,
          :line              => 'foo2',
          :ensure            => 'absent',
          :match             => 'o$',
          :match_for_absence => true,
        }
      )
      @provider = provider_class.new(@resource)
    end

    it 'should find a line to match' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2")
      end
      expect(@provider.exists?).to be_truthy
    end

    it 'should remove one line if it matches' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2")
      end
      @provider.destroy
      expect(File.read(@tmpfile)).to eql("foo1\nfoo2")
    end

    it 'should raise an error if more than one line matches' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2\nfoo\nfoo")
      end
      expect { @provider.destroy }.to raise_error(Puppet::Error, /More than one line/)
    end

    it 'should remove multiple lines if :multiple is true' do
      @resource = Puppet::Type::File_line.new(
        {
          :name              => 'foo',
          :path              => @tmpfile,
          :line              => 'foo2',
          :ensure            => 'absent',
          :match             => 'o$',
          :multiple          => true,
          :match_for_absence => true,
        }
      )
      @provider = provider_class.new(@resource)
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2\nfoo\nfoo")
      end
      @provider.destroy
      expect(File.read(@tmpfile)).to eql("foo1\nfoo2\n")
    end

    it 'should ignore the match if match_for_absence is not specified' do
      @resource = Puppet::Type::File_line.new(
        {
          :name     => 'foo',
          :path     => @tmpfile,
          :line     => 'foo2',
          :ensure   => 'absent',
          :match    => 'o$',
        }
      )
      @provider = provider_class.new(@resource)
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2")
      end
      @provider.destroy
      expect(File.read(@tmpfile)).to eql("foo1\nfoo\n")
    end

    it 'should ignore the match if match_for_absence is false' do
      @resource = Puppet::Type::File_line.new(
        {
          :name              => 'foo',
          :path              => @tmpfile,
          :line              => 'foo2',
          :ensure            => 'absent',
          :match             => 'o$',
          :match_for_absence => false,
        }
      )
      @provider = provider_class.new(@resource)
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2")
      end
      @provider.destroy
      expect(File.read(@tmpfile)).to eql("foo1\nfoo\n")
    end

  end

end
