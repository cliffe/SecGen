require 'pathname'
require Pathname.new(__FILE__).dirname + 'chocolatey_version'
require Pathname.new(__FILE__).dirname + 'chocolatey_install'

module PuppetX
  module Chocolatey
    module ChocolateyCommon

      ## determines if C# version of choco
      FIRST_COMPILED_CHOCO_VERSION = '0.9.9.0'
      MINIMUM_SUPPORTED_CHOCO_VERSION_EXIT_CODES = '0.9.10.0'
      MINIMUM_SUPPORTED_CHOCO_UNINSTALL_SOURCE = '0.9.10.0'

      def file_exists?(path)
        File.exist?(path)
      end
      module_function :file_exists?

      def chocolatey_command
        if Puppet::Util::Platform.windows?
          # When attempting to find the choco command executable, the following
          # paths are checked:
          # - Start with the install_path. If choco is found with environment
          #   variables through the registry or a check on the
          #   ChocolateyInstall env var (first install of Choco may only have
          #   this), then use that path.
          # - Next look to the most commonly used install location (ProgramData)
          # - Fall back to the older install location for older installations
          # - If all else fails, attempt to find Chocolatey in the default place
          #   it installs
          chocoInstallPath = PuppetX::Chocolatey::ChocolateyInstall.install_path

          chocopath =  (chocoInstallPath if (chocoInstallPath && file_exists?("#{chocoInstallPath}\\bin\\choco.exe"))) ||
              ('C:\ProgramData\chocolatey' if file_exists?('C:\ProgramData\chocolatey\bin\choco.exe')) ||
              ('C:\Chocolatey' if file_exists?('C:\Chocolatey\bin\choco.exe')) ||
              "#{ENV['ALLUSERSPROFILE']}\\chocolatey"

          chocopath += '\bin\choco.exe'
        else
          chocopath = 'choco.exe'
        end

        chocopath
      end
      module_function :chocolatey_command

      def set_env_chocolateyinstall
        ENV['ChocolateyInstall'] = PuppetX::Chocolatey::ChocolateyInstall.install_path
      end
      module_function :set_env_chocolateyinstall

      def choco_version
        @chocoversion ||= self.strip_beta_from_version(PuppetX::Chocolatey::ChocolateyVersion.version)
      end
      module_function :choco_version

      def self.strip_beta_from_version(value)
        return nil if value.nil?

        value.split(/-/)[0]
      end

      def choco_config_file
        chocoInstallPath = PuppetX::Chocolatey::ChocolateyInstall.install_path
        choco_config = "#{chocoInstallPath}\\config\\chocolatey.config"

        # choco may be installed, but a config file doesn't exist until the
        # first run of choco - trigger that by checking the version
        choco_run_ensure_config = choco_version

        return choco_config if file_exists?(choco_config)

        old_choco_config = "#{chocoInstallPath}\\chocolateyinstall\\chocolatey.config"

        return old_choco_config if file_exists?(old_choco_config)

        return nil
      end
      module_function :choco_config_file

      # clears the cached values
      def clear_cached_values
        @chocoversion = nil
        @compiled_choco = nil
      end
      module_function :clear_cached_values

    end
  end
end
