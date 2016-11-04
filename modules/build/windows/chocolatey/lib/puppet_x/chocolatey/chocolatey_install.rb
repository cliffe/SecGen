module PuppetX
  module Chocolatey
    class ChocolateyInstall

      def self.install_path
        if Puppet::Util::Platform.windows?
        require 'win32/registry'

        value = nil
        begin
          hive = Win32::Registry::HKEY_LOCAL_MACHINE
          hive.open('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', Win32::Registry::KEY_READ | 0x100) do |reg|
            value = reg['ChocolateyInstall']
          end
        rescue Win32::Registry::Error => e
          value = nil
        end
      end

      value || 'C:\ProgramData\chocolatey'
      end

    end
  end
end
