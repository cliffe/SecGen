Facter.add('chocolateyversion') do
  setcode do
    value = nil

    choco_path = "#{Facter.value(:choco_install_path)}\\bin\\choco.exe"
    if Puppet::Util::Platform.windows? && File.exist?(choco_path)
      begin
        old_choco_message = 'Please run chocolatey /? or chocolatey help - chocolatey v'
        #Facter::Core::Execution.exec is 2.0.1 forward
        value = Facter::Util::Resolution.exec("#{choco_path} -v").gsub(old_choco_message,'').strip
      rescue StandardError => e
        value = '0'
      end
    end

    value || '0'
  end
end
