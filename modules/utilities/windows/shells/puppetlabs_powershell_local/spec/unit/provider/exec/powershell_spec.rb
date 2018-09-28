#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util'
require 'puppet_x/puppetlabs/powershell/powershell_manager'
require 'fileutils'

describe Puppet::Type.type(:exec).provider(:powershell) do

  # Override the run value so we can test the super call
  # There is no real good way to do this otherwise, previously we were
  # testing Puppet internals that changed in 3.4.0 and made the specs
  # no longer work the way they were originally specified.
  Puppet::Type::Exec::ProviderPowershell.instance_eval do
    alias_method :run_spec_override, :run
  end

  let(:command)  { '$(Get-WMIObject Win32_Account -Filter "SID=\'S-1-5-18\'") | Format-List' }
  let(:args) { '-NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -Command -' }
  let(:resource) { Puppet::Type.type(:exec).new(:command => command, :provider => :powershell) }
  let(:provider) { described_class.new(resource) }

  let(:powershell) {
    if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
      "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
    elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
      "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
    else
      'powershell.exe'
    end
  }

  describe "#run" do
    context "stubbed calls" do
      before :each do
        PuppetX::PowerShell::PowerShellManager.stubs(:supported?).returns(false)
        Puppet::Provider::Exec.any_instance.stubs(:run)
      end

      it "should call exec run" do
        Puppet::Type::Exec::ProviderPowershell.any_instance.expects(:run)

        provider.run_spec_override(command)
      end

      it "should call cmd.exe /c" do
        Puppet::Type::Exec::ProviderPowershell.any_instance.expects(:run)
          .with(regexp_matches(/^cmd.exe \/c/), anything)

        provider.run_spec_override(command)
      end

      it "should quote powershell.exe path", :if => Puppet.features.microsoft_windows? do
        Puppet::Type::Exec::ProviderPowershell.any_instance.expects(:run).
          with(regexp_matches(/"#{Regexp.escape(powershell)}"/), false)

        provider.run_spec_override(command)
      end

      it "should quote the path to the temp file" do
        path = 'C:\Users\albert\AppData\Local\Temp\puppet-powershell20130715-788-1n66f2j.ps1'

        provider.expects(:write_script).with(command).yields(path)
        Puppet::Type::Exec::ProviderPowershell.any_instance.expects(:run).
          with(regexp_matches(/^cmd.exe \/c ".* < "#{Regexp.escape(path)}""/), false)

        provider.run_spec_override(command)
      end

      it "should supply default arguments to supress user interaction" do
        Puppet::Type::Exec::ProviderPowershell.any_instance.expects(:run).
          with(regexp_matches(/^cmd.exe \/c ".* #{args} < .*"/), false)

        provider.run_spec_override(command)
      end
    end

    context "actual runs", :if => Puppet.features.microsoft_windows? do
      it "returns the output and status" do
        output, status = provider.run(command)

        expect(output).to match(/SID\s+:\s+S-1-5-18/)
        expect(status.exitstatus).to eq(0)
      end

      it "returns true if the `onlyif` check command succeeds" do
        resource[:onlyif] = command

        expect(resource.parameter(:onlyif).check(command)).to eq(true)
      end

      it "returns false if the `unless` check command succeeds" do
        resource[:unless] = command

        expect(resource.parameter(:unless).check(command)).to eq(false)
      end

      it "runs commands properly that output to multiple streams" do
        command = 'echo "foo"; [System.Console]::Error.WriteLine("bar"); cmd.exe /c foo.exe'
        output, status = provider.run(command)

        if PuppetX::PowerShell::PowerShellManager.supported?
          expected = "foo\r\n"
        else
          # when PowerShellManager is not used, the v1 style module collected
          # all streams inside of a single output string
          expected = [
            "foo\n",
            "bar\n'",
            "foo.exe' is not recognized as an internal or external command,\n",
            "operable program or batch file.\n"
          ].join('')
        end

        expect(output).to eq(expected)
        expect(status.exitstatus).to eq(1)
      end
    end
  end

  describe "#checkexe" do
    it "should skip checking the exe" do
      expect(provider.checkexe(command)).to be_nil
    end
  end

  describe "#validatecmd" do
    it "should always successfully validate the command to execute" do
      expect(provider.validatecmd(command)).to eq(true)
    end
  end

  describe 'when specifying a working directory' do
    describe 'that does not exist' do
      let(:work_dir)  {
        if Puppet.features.microsoft_windows?
          "#{ENV['SYSTEMROOT']}\\some\\directory\\that\\does\\not\\exist"
        else
          '/some/directory/that/does/not/exist'
        end
      }
      let(:command)  { 'exit 0' }
      let(:resource) { Puppet::Type.type(:exec).new(:command => command, :provider => :powershell, :cwd => work_dir) }
      let(:provider) { described_class.new(resource) }

      it 'emits an error when working directory does not exist' do
        expect { provider.run(command) }.to raise_error(/Working directory .+ does not exist/)
      end
    end
  end

  describe 'when applying a catalog' do
    let(:manifests) { <<-MANIFEST
      exec { 'PS':
        command   => 'exit 0',
        provider  => powershell,
      }
    MANIFEST
    }
    let(:tmpdir) { Dir.mktmpdir('statetmp').encode!(Encoding::UTF_8) }

    before :each do
      # a statedir setting must now exist per the new transactionstore code
      # introduced in Puppet 4.6 for corrective changes, as a new YAML file
      # called transactionstore.yaml will be written under this path
      # which defaults to c:\dev\null when not set on Windows
      Puppet[:statedir] = tmpdir
    end

    after :each do
      FileUtils.rm_rf(tmpdir)
    end

    def compile_to_catalog(string, node = Puppet::Node.new('foonode'))
      Puppet[:code] = string

      # see lib/puppet/indirector/catalog/compiler.rb#filter
      Puppet::Parser::Compiler.compile(node).filter { |r| r.virtual? }
    end

    def compile_to_ral(manifest)
      catalog = compile_to_catalog(manifest)
      ral = catalog.to_ral
      ral.finalize
      ral
    end

    def apply_compiled_manifest(manifest)
      catalog = compile_to_ral(manifest)

      # ensure compilation works from Puppet 3.0.0 forward
      args = [catalog, Puppet::Transaction::Report.new('apply')]
      args << Puppet::Graph::SequentialPrioritizer.new if defined?(Puppet::Graph)
      transaction = Puppet::Transaction.new(*args)
      transaction.evaluate
      transaction.report.finalize_report

      transaction
    end

    it 'does not emit an irrelevant upgrade message when in a non-Windows environment',
      :if => !Puppet.features.microsoft_windows? do

      expect(PuppetX::PowerShell::PowerShellManager.supported?).to eq(false)

      # run should never be called on an unsuitable provider
      Puppet::Type::Exec::ProviderPowershell.any_instance.expects(:run).never
      # and therefore neither should our upgrade message
      Puppet::Type::Exec::ProviderPowershell.expects(:upgrade_message).never

      apply_compiled_manifest(manifest)
    end

    it 'does not emit a warning message when PowerShellManager is usable in a Windows environment',
      :if => Puppet.features.microsoft_windows? do

      PuppetX::PowerShell::PowerShellManager.stubs(:win32console_enabled?).returns(false)

      expect(PuppetX::PowerShell::PowerShellManager.supported?).to eq(true)

      # given PowerShellManager is supported, never emit an upgrade message
      Puppet::Type::Exec::ProviderPowershell.expects(:upgrade_message).never

      apply_compiled_manifest(manifest)
    end

    it 'emits a warning message when PowerShellManager cannot be used in a Windows environment',
      :if => Puppet.features.microsoft_windows? do

      # pretend we're Ruby 1.9.3 / Puppet 3.x x86
      PuppetX::PowerShell::PowerShellManager.stubs(:win32console_enabled?).returns(true)

      expect(PuppetX::PowerShell::PowerShellManager.supported?).to eq(false)

      # given PowerShellManager is NOT supported, emit an upgrade message
      Puppet::Type::Exec::ProviderPowershell.expects(:upgrade_message).once

      apply_compiled_manifest(manifest)
    end
  end
end
