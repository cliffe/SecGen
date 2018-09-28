# = Class: registry::service_example
#
#   This is an example of how to use the registry::service defined resource
#   type included in this module.
#
# = Parameters
#
# = Actions
#
# = Requires
#
# = Sample Usage
#
#   include registry::service_example
#
#
# (MARKUP: http://links.puppetlabs.com/puppet_manifest_documentation)
class registry::service_example {
  # Define a new service named "Puppet Test" that is disabled.
  registry::service { 'PuppetExample1':
    display_name => 'Puppet Example 1',
    description  =>
    'This is a simple example managing the
      registry entries for a Windows Service',
    command      => 'C:\PuppetExample1.bat',
    start        => 'disabled',
  }
  registry::service { 'PuppetExample2':
    display_name => 'Puppet Example 2',
    description  =>
    'This is a simple example
      managing the registry entries for a Windows Service',
    command      => 'C:\PuppetExample2.bat',
    start        => 'disabled',
  }
}
