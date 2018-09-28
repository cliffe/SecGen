require 'chocolatey_helper'
require 'beaker-windows'
test_name 'MODULES-3037 - 97729 Install known good package via manifest and remove via manifest'
confine(:to, :platform => 'windows')

# arrange
package_name = 'vlc'
package_exe_path = %{C:\\'Program Files\\VideoLAN\\VLC\\vlc.exe'}
software_uninstall_command = %{cmd.exe /C C:\\'Program Files\\VideoLAN\\VLC\\uninstall.exe' /S}

chocolatey_package_manifest = <<-PP
  package { "#{package_name}":
    ensure  => present,
    provider => chocolatey,
    source => 'http://nexus.delivery.puppetlabs.net/service/local/nuget/choco-pipeline-tests/'
  }
PP

# teardown
teardown do
  on(agent, exec_ps_cmd("test-path #{package_exe_path}")) do |result|
      if (result.output =~ /True/i)
        retry_on(agent, exec_ps_cmd(software_uninstall_command))
      end
  end
  #TODO: should we validate that the software was removed successfully here?
end

#validate
step "should not have valid version of #{package_name}"
on(agent, exec_ps_cmd("test-path #{package_exe_path}")) do |result|
  assert_match(/False/i, result.output, "#{package_name} was present before application of manifest.")
end


#act
step 'Apply manifest'
apply_manifest(chocolatey_package_manifest, :catch_failures => true) do |result|
  assert_match(/Notice\: \/Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: created/, result.stdout, "stdout did not report package creation of #{package_name}")
end

#validate
step "should have valid version of #{package_name}"
on(agent, exec_ps_cmd("test-path #{package_exe_path}")) do |result|
  assert_match(/True/i, result.output, "#{package_name} was not present after application of manifest.")
end

#arrange
chocolatey_package_manifest = <<-PP
  package { "#{package_name}":
    ensure  => absent,
    provider => chocolatey,
  }
PP

#act
step "Uninstall #{package_name} package via manifest"
apply_manifest(chocolatey_package_manifest, :catch_failures => true) do |result|
#validate
  assert_match(/Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: removed/, result.stdout, "stdout did not report package removal of #{package_name}")
end

