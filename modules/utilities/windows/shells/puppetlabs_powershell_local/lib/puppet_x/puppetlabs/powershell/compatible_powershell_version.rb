require File.join(File.dirname(__FILE__), 'powershell_version')

module PuppetX
  module PuppetLabs
    module PowerShell
      class CompatiblePowerShellVersion
        def self.compatible_version?
          value = false

          powershell_version = PuppetX::PuppetLabs::PowerShell::PowerShellVersion.version

          return false if powershell_version.nil?

          # PowerShell v1 - definitely not good to go. Really the entire module
          # may not even work but I digress
          return false if Gem::Version.new(powershell_version) < Gem::Version.new(2)

          # PowerShell v3+, we are good to go b/c .NET 4+
          # https://msdn.microsoft.com/en-us/powershell/scripting/setup/windows-powershell-system-requirements
          # Look at Microsoft .NET Framwork Requirements section.
          if Gem::Version.new(powershell_version) >= Gem::Version.new(3)
            return true
          end

          # If we are using PowerShell v2, we need to see what the latest
          # version of .NET is that we have
          # https://msdn.microsoft.com/en-us/library/hh925568.aspx
          if Puppet::Util::Platform.windows?
            require 'win32/registry'

            begin
              # At this point in the check, PowerShell is using .NET Framework
              # 2.x family, so we only need to verify v3.5 key exists.
              # If we were verifying all compatible types we would look for
              # any of these keys: v3.5, v4.0, v4
              hive = Win32::Registry::HKEY_LOCAL_MACHINE
              # redirection doesn't actually matter here - disable it anyway
              hive.open('SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5', Win32::Registry::KEY_READ | 0x100) do |reg|
                value = true
              end
            rescue Win32::Registry::Error => e
              value = false
            end
          end

          value
        end
      end
    end
  end
end
