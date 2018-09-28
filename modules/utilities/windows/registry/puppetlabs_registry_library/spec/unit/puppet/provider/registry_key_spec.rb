#! /usr/bin/env ruby

require 'spec_helper'
require 'puppet/type/registry_key'

describe Puppet::Type.type(:registry_key).provider(:registry), :if => Puppet.features.microsoft_windows? do
  let (:catalog) do Puppet::Resource::Catalog.new end
  let (:type) { Puppet::Type.type(:registry_key) }

  puppet_key = "SOFTWARE\\Puppet Labs"
  subkey_name ="PuppetRegProviderTest"

  before(:each) do
    # problematic Ruby codepath triggers a conversion of UTF-16LE to
    # a local codepage which can totally break when that codepage has no
    # conversion from the given UTF-16LE characters to local codepage
    # a prime example is that IBM437 has no conversion from a Unicode en-dash
    Win32::Registry.any_instance.expects(:export_string).never

    Win32::Registry.any_instance.expects(:delete_value).never
    Win32::Registry.any_instance.expects(:delete_key).never

    if RUBY_VERSION >= '2.1'
      # also, expect that we're not using Rubys each_key / each_value which exhibit bad behavior
      Win32::Registry.any_instance.expects(:each_key).never
      Win32::Registry.any_instance.expects(:each_value).never
    end
  end

  describe "#destroy" do
    it "can destroy a randomly created key" do

      guid = SecureRandom.uuid
      reg_key = type.new(:path => "hklm\\#{puppet_key}\\#{subkey_name}\\#{guid}", :provider => described_class.name)
      already_exists = reg_key.provider.exists?
      already_exists.should be_falsey

      # something has gone terribly wrong here, pull the ripcord
      break if already_exists

      reg_key.provider.create
      reg_key.provider.exists?.should be true

      # test FFI code
      reg_key.provider.destroy
      reg_key.provider.exists?.should be false
    end
  end

  describe "#purge_values", :if => Puppet.features.microsoft_windows? do
    let (:guid) { SecureRandom.uuid }
    let (:reg_path) { "#{puppet_key}\\#{subkey_name}\\Unicode-#{guid}" }

    def bytes_to_utf8(bytes)
      bytes.pack('c*').force_encoding(Encoding::UTF_8)
    end

    after(:each) do
      reg_key = type.new(:path => "hklm\\#{reg_path}", :provider => described_class.name)
      reg_key.provider.destroy

      reg_key.provider.exists?.should be_falsey
    end

    context "with ANSI strings on all Ruby platforms" do
      before(:each) do
        Win32::Registry::HKEY_LOCAL_MACHINE.create(reg_path,
          Win32::Registry::KEY_ALL_ACCESS |
          PuppetX::Puppetlabs::Registry::KEY_WOW64_64KEY) do |reg_key|
            reg_key.write('hi', Win32::Registry::REG_SZ, 'yes')
        end
      end

      it "does not raise an error" do
        reg_key = type.new(:catalog => catalog,
                           :ensure => :absent,
                           :name => "hklm\\#{reg_path}",
                           :purge_values => true,
                           :provider => described_class.name)

        catalog.add_resource(reg_key)

        expect { reg_key.eval_generate }.to_not raise_error
      end
    end

    context "with unicode", :if => Puppet.features.microsoft_windows? && RUBY_VERSION =~ /^2\./ do
      before(:each) do
        # create temp registry key with Unicode values
        Win32::Registry::HKEY_LOCAL_MACHINE.create(reg_path,
          Win32::Registry::KEY_ALL_ACCESS |
          PuppetX::Puppetlabs::Registry::KEY_WOW64_64KEY) do |reg_key|
            endash = bytes_to_utf8([0xE2, 0x80, 0x93])
            tm = bytes_to_utf8([0xE2, 0x84, 0xA2])

          reg_key.write(endash, Win32::Registry::REG_SZ, tm)
        end
      end

    it "does not use Rubys each_value, which unnecessarily string encodes" do
      # endash and tm undergo LOCALE conversion during Rubys each_value
      # which will generally lead to a conversion exception
      reg_key = type.new(:catalog => catalog,
                         :ensure => :absent,
                         :name => "hklm\\#{reg_path}",
                         :purge_values => true,
                         :provider => described_class.name)

        catalog.add_resource(reg_key)

        # this will trigger
        expect { reg_key.eval_generate }.to_not raise_error
      end
    end
  end
end
