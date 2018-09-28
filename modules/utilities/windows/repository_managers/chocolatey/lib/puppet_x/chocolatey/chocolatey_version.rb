require 'pathname'
require Pathname.new(__FILE__).dirname + 'chocolatey_install'

module PuppetX
  module Chocolatey
    class ChocolateyVersion

      OLD_CHOCO_MESSAGE = "Please run chocolatey /? or chocolatey help - chocolatey v"

      def self.version
        version = nil
        choco_path = "#{PuppetX::Chocolatey::ChocolateyInstall.install_path}\\bin\\choco.exe"
        if Puppet::Util::Platform.windows? && File.exist?(choco_path)
          begin
            # call `choco -v`
            # - new choco will output a single value e.g. `0.9.9`
            # - old choco is going to return the default output e.g. `Please run chocolatey /?`
            version = Puppet::Util::Execution.execute("#{choco_path} -v").gsub(OLD_CHOCO_MESSAGE,'')
            # - other messages, such as upgrade warnings or warnings about
            #   installing the licensed extension once the license is installed
            #   may show up when running this comamnd. Remove those as well
            version = version.split(/\r\n|\n|\r/).last.strip unless version.nil?
          rescue StandardError => e
            version = '0'
          end
        end

        version
      end
    end
  end
end
