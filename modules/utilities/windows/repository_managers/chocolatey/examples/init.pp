# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation errors
# and view a log of events) or by fully applying the test in a virtual environment
# (to compare the resulting system state to the desired state).
#
# Learn more about module testing here: http://docs.puppetlabs.com/guides/tests_smoke.html
#
# With symlinks on Windows, please run the following command an administrative command prompt (substituting the proper directories):

package { $pkg:
  ensure   => 'latest',
  provider => 'chocolatey',
}

#    mklink /D C:\ProgramData\PuppetLabs\puppet\etc\modules\chocolatey C:\code\puppetlabs\puppetlabs-chocolatey
#    mklink /D C:\ProgramData\PuppetLabs\code\environments\production\modules\chocolatey C:\code\puppetlabs\puppetlabs-chocolatey

chocolateysource { 'local':
  location => 'c:\packages',
}
