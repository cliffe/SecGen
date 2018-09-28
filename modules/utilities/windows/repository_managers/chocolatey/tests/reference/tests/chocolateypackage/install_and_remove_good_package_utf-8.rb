# require 'chocolatey_helper'
# require 'beaker-windows'
# test_name 'MODULES-3037 - C97738 Install known good package with utf-8 via manifest and remove via manifest'
# confine(:to, :platform => 'windows')
#
# # arrange
# package_name = '竹ChocolateyGUIÖ'
# package_exe_path = %{C:\\'Program Files (x86)\\ChocolateyGUI\\ChocolateyGUI.exe'}
# software_uninstall_command = %{msiexec /x C:\\ProgramData\\chocolatey\\lib\\竹ChocolateyGUIÖ\\tools\\竹ChocolateyGUIÖ.msi /q}.force_encoding("ASCII-8BIT")
#
# chocolatey_package_manifest = <<-PP
#   package { "#{package_name}":
#     ensure  => present,
#     provider => chocolatey,
#     source => 'http://nexus.delivery.puppetlabs.net/service/local/nuget/choco-pipeline-tests/'
#   }
# PP
#
# # teardown
# teardown do
#   on(agent, exec_ps_cmd("test-path #{package_exe_path}")) do |result|
#     if (result.output =~ /True/i)
#       on(agent, exec_ps_cmd(software_uninstall_command))
#     end
#   end
#   on(agent, exec_ps_cmd("test-path #{package_exe_path}")) do |result|
#     assert_match(/False/i, result.output, "#{package_name} was present after uninstall.")
#   end
# end
#
# #validate
# step "should not have valid version of #{package_name}"
# on(agent, exec_ps_cmd("test-path #{package_exe_path}")) do |result|
#   assert_match(/False/i, result.output, "#{package_name} was present before application of manifest.")
# end
#
#
# #act
# step 'Apply manifest'
# apply_manifest(chocolatey_package_manifest, :catch_failures => true) do |result|
#   assert_match(/Notice\: \/Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: created/, result.stdout, "stdout did not report package creation of #{package_name}")
# end
#
# #validate
# step "should have valid version of #{package_name}"
# on(agent, exec_ps_cmd("test-path #{package_exe_path}")) do |result|
#   assert_match(/True/i, result.output, "#{package_name} was not present after application of manifest.")
# end
#
# #arrange
# chocolatey_package_manifest = <<-PP
#   package { "#{package_name}":
#     ensure  => absent,
#     provider => chocolatey,
#   }
# PP
#
# #act
# step "Uninstall #{package_name} package via manifest"
# apply_manifest(chocolatey_package_manifest, :catch_failures => true) do |result|
# #validate
#   expect_failure('Expected to fail because of MODULES-3541') do
#     assert_match(/Stage\[main\]\/Main\/Package\[#{package_name}\]\/ensure\: removed/, result.stdout, "stdout did not report package removal of #{package_name}")
#   end
# end
