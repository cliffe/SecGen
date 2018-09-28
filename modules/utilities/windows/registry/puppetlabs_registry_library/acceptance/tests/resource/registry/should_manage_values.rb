require 'pathname'
require 'systest/util/registry'
# Include our utility methods in the singleton class of the test case instance.
class << self
  include Systest::Util::Registry
end

test_name "Registry Value Management"

# Generate a unique key name
keyname = "PuppetLabsTest_Value_#{randomstring(8)}"
# This is the keypath we'll use for this entire test.  We will actually create this key and delete it.
vendor_path = "HKLM\\Software\\Vendor"
keypath = "#{vendor_path}\\#{keyname}"

def getManifest(keypath, vendor_path, phase)
  manifest = <<P1
  notify { fact_phase: message => "fact_phase: #{phase}" }
  registry_key { '#{vendor_path}': ensure => present }
  if $architecture == 'x64' {
    registry_key { '32:#{vendor_path}': ensure => present }
  }
  Registry_key { ensure => present }
  registry_key { '#{keypath}': }
  registry_key { '#{keypath}\\SubKey1': }
  registry_key { '#{keypath}\\SubKey2': }
  if $architecture == 'x64' {
    registry_key { '32:#{keypath}': }
    registry_key { '32:#{keypath}\\SubKey1': }
    registry_key { '32:#{keypath}\\SubKey2': }
  }

  # The Default Value
  registry_value { '#{keypath}\\SubKey1\\\\':
    data => "Default Data phase=#{phase}",
  }
  registry_value { '#{keypath}\\SubKey2\\\\':
    type => array,
    data => [ "Default Data L1 phase=#{phase}", "Default Data L2 phase=#{phase}" ],
  }

  # String Values
  registry_value { '#{keypath}\\SubKey1\\ValueString1':
    data => "Should be a string phase=#{phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueString2':
    type => string,
    data => "Should be a string phase=#{phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueString3':
    ensure => present,
    type   => string,
    data   => "Should be a string phase=#{phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueString4':
    data   => "Should be a string phase=#{phase}",
    type   => string,
    ensure => present,
  }

  if $architecture == 'x64' {
    # String Values
    registry_value { '32:#{keypath}\\SubKey1\\ValueString1':
      data => "Should be a string phase=#{phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueString2':
      type => string,
      data => "Should be a string phase=#{phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueString3':
      ensure => present,
      type   => string,
      data   => "Should be a string phase=#{phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueString4':
      data   => "Should be a string phase=#{phase}",
      type   => string,
      ensure => present,
    }
  }

  # Array Values
  registry_value { '#{keypath}\\SubKey1\\ValueArray1':
    type => array,
    data => "Should be an array L1 phase=#{phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueArray2':
    type => array,
    data => [ "Should be an array L1 phase=#{phase}" ],
  }
  registry_value { '#{keypath}\\SubKey1\\ValueArray3':
    type => array,
    data => [ "Should be an array L1 phase=#{phase}",
              "Should be an array L2 phase=#{phase}" ],
  }
  registry_value { '#{keypath}\\SubKey1\\ValueArray4':
    ensure => present,
    type   => array,
    data   => [ "Should be an array L1 phase=#{phase}",
                "Should be an array L2 phase=#{phase}" ],
  }
  registry_value { '#{keypath}\\SubKey1\\ValueArray5':
    data   => [ "Should be an array L1 phase=#{phase}",
                "Should be an array L2 phase=#{phase}" ],
    type   => array,
    ensure => present,
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray1':
      type => array,
      data => "Should be an array L1 phase=#{phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray2':
      type => array,
      data => [ "Should be an array L1 phase=#{phase}" ],
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray3':
      type => array,
      data => [ "Should be an array L1 phase=#{phase}",
                "Should be an array L2 phase=#{phase}" ],
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray4':
      ensure => present,
      type   => array,
      data   => [ "Should be an array L1 phase=#{phase}",
                  "Should be an array L2 phase=#{phase}" ],
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueArray5':
      data   => [ "Should be an array L1 phase=#{phase}",
                  "Should be an array L2 phase=#{phase}" ],
      type   => array,
      ensure => present,
    }
  }

  # Expand Values
  registry_value { '#{keypath}\\SubKey1\\ValueExpand1':
    type => expand,
    data => "%SystemRoot% - Should be a REG_EXPAND_SZ phase=#{phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueExpand2':
    type   => expand,
    data   => "%SystemRoot% - Should be a REG_EXPAND_SZ phase=#{phase}",
    ensure => present,
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueExpand1':
      type => expand,
      data => "%SystemRoot% - Should be a REG_EXPAND_SZ phase=#{phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueExpand2':
      type   => expand,
      data   => "%SystemRoot% - Should be a REG_EXPAND_SZ phase=#{phase}",
      ensure => present,
    }
  }

  # DWORD Values
  registry_value { '#{keypath}\\SubKey1\\ValueDword1':
    type => dword,
    data => #{phase},
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueDword1':
      type => dword,
      data => #{phase},
    }
  }

  # QWORD Values
  registry_value { '#{keypath}\\SubKey1\\ValueQword1':
    type => qword,
    data => #{phase},
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueQword1':
      type => qword,
      data => #{phase},
    }
  }

  # Binary Values
  registry_value { '#{keypath}\\SubKey1\\ValueBinary1':
    type => binary,
    data => "#{phase}",
  }
  registry_value { '#{keypath}\\SubKey1\\ValueBinary2':
    type => binary,
    data => "DE AD BE EF CA F#{phase}"
  }
  if $architecture == 'x64' {
    registry_value { '32:#{keypath}\\SubKey1\\ValueBinary1':
      type => binary,
      data => "0#{phase}",
    }
    registry_value { '32:#{keypath}\\SubKey1\\ValueBinary2':
      type => binary,
      data => "DEAD BEEF CAF#{phase}"
    }
  }
P1
end

step "Start testing should_manage_values" do
  windows_agents.each do |agent|
    x64 = x64?(agent)

    # A set of keys we expect Puppet to create
    phase1_resources_created = [
        /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\].ensure: created/,
        /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\].ensure: created/,
        /Registry_key\[HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey2\].ensure: created/,
    ]

    if x64
      phase1_resources_created += [
          /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\].ensure: created/,
          /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\].ensure: created/,
          /Registry_key\[32:HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey2\].ensure: created/,
      ]
    end

    # A set of values we expect Puppet to change in Phase 2
    phase2_resources_changed = Array.new

    prefixes = ['']
    prefixes << '32:' if x64

    # This is just to save a whole bunch of copy / paste
    prefixes.each do |prefix|
      # We should have created 4 REG_SZ values
      1.upto(4).each do |idx|
        phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueString#{idx}\].ensure: created/
        phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueString#{idx}\].data: data changed 'Should be a string phase=1' to 'Should be a string phase=2'/
      end
      # We should have created 5 REG_MULTI_SZ values
      1.upto(5).each do |idx|
        phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueArray#{idx}\].ensure: created/
      end

      # The first two array items are an exception
      1.upto(2).each do |idx|
        phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueArray#{idx}\].data: data changed 'Should be an array L1 phase=1' to 'Should be an array L1 phase=2'/
      end

      # The rest of the array items are OK and have 2 "lines" each.
      3.upto(5).each do |idx|
        phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueArray#{idx}\].data: data changed 'Should be an array L1 phase=1,Should be an array L2 phase=1' to 'Should be an array L1 phase=2,Should be an array L2 phase=2'/
      end

      # We should have created 2 REG_EXPAND_SZ values
      1.upto(2).each do |idx|
        phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueExpand#{idx}\].ensure: created/
        phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueExpand#{idx}\].data: data changed '%SystemRoot% - Should be a REG_EXPAND_SZ phase=1' to '%SystemRoot% - Should be a REG_EXPAND_SZ phase=2'/
      end
      # We should have created 1 qword
      1.upto(1).each do |idx|
        phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueQword#{idx}\].ensure: created/
        phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueQword#{idx}\].data: data changed '1' to '2'/
      end
      # We should have created 1 dword
      1.upto(1).each do |idx|
        phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueDword#{idx}\].ensure: created/
        phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueDword#{idx}\].data: data changed '1' to '2'/
      end
      # We should have created 2 binary values
      1.upto(2).each do |idx|
        phase1_resources_created << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueBinary#{idx}\].ensure: created/
      end
      # We have different data for the binary values
      phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueBinary1\].data: data changed '01' to '02'/
      phase2_resources_changed << /Registry_value\[#{prefix}HKLM.Software.Vendor.PuppetLabsTest\w+\\SubKey1\\ValueBinary2\].data: data changed 'de ad be ef ca f1' to 'de ad be ef ca f2'/
    end


    step "Registry Values - Phase 1.a - Create some values"
    apply_manifest_on agent, getManifest(keypath, vendor_path,'1'), get_apply_opts do
      assert_no_match(/err:/, result.stdout, "Expected no error messages.")
      phase1_resources_created.each do |val_re|
        assert_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
      end
    end

    step "Registry Values - Phase 1.b - Make sure Puppet is idempotent"
    apply_manifest_on agent, getManifest(keypath, vendor_path,'1'), get_apply_opts do
      phase1_resources_created.each do |val_re|
        assert_no_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
      end
      assert_no_match(/err:/, result.stdout, "Expected no error messages.")
    end

    step "Registry Values - Phase 2.a - Change some values"
    apply_manifest_on agent, getManifest(keypath, vendor_path, '2'), get_apply_opts do
      assert_no_match(/err:/, result.stdout, "Expected no error messages.")
      phase2_resources_changed.each do |val_re|
        assert_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
      end
    end

    step "Registry Values - Phase 2.b - Make sure Puppet is idempotent"
    apply_manifest_on agent, getManifest(keypath, vendor_path,'2'), get_apply_opts do
      phase2_resources_changed.each do |val_re|
        assert_no_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
      end
      assert_no_match(/err:/, result.stdout, "Expected no error messages.")
    end

    step "Registry Values - Phase 3 - Check the default value (#14572)"
    # (#14572) This test uses the 'native' version of reg.exe to read the
    # default value of a registry key.  It should contain the string shown in
    # val_re.
    dir = native_sysdir(agent)
    if not dir
      Log.warn("Cannot query 64-bit view of registry from 32-bit process, skipping")
    else
      on agent, "#{dir}/reg.exe query '#{keypath}\\Subkey1'" do
        val_re = /\(Default\)    REG_SZ    Default Data phase=2/i
        assert_match(val_re, result.stdout, "Expected output to contain #{val_re.inspect}.")
      end
    end
  end
end

