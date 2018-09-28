# = Class: registry::compliance_example
#
#   This class provides an example of how to use the audit metaparameter to
#   inspect registry_key and registry_value resources with the Compliance
#   feature of Puppet Enterprise.
#
# = Parameters
#
# = Actions
#
# = Requires
#
# = Sample Usage
#
#   include registry::compliance_example
#
# (MARKUP: http://links.puppetlabs.com/puppet_manifest_documentation)
class registry::compliance_example {
  $key_path = 'HKLM\Software\Vendor\Puppet Labs\Examples\Compliance'

  case $::registry_compliance_example_mode {
    audit: {
      $mode = 'audit'
    }
    default: {
      $mode = 'setup'
      notify { 'compliance_example_mode_info':
        message => 'Switch to audit mode using
        \$env:FACTER_REGISTRY_COMPLIANCE_EXAMPLE_MODE = \'audit\'',
        before  => Notify['compliance_example_mode']
      }
    }
  }

  notify { 'compliance_example_mode':
    message => "Registry compliance example mode: ${mode}",
  }

  # Resource Defaults
  Registry_key {
    ensure => $mode ? {
      setup   => present,
      default => undef
    },
    purge_values => $mode ? {
      setup   => true,
      default => false,
    },
  }
  Registry_value {
    ensure => $mode ? {
      setup   => present,
      default => undef,
    },
    type   => $mode ? {
      setup   => string,
      default => undef,
    },
    data   => $mode ? {
      setup   => 'Puppet Default Data',
      default => undef,
    },
    audit  => $mode ? {
      setup   => undef,
      default => all,
    },
  }

  # Create the nested key structure we want to audit.  The resource defaults
  # will determine the properties managed or audited.
  registry_key { $key_path: }
  registry_key { "${key_path}\\SubKeyA": }
  registry_key { "${key_path}\\SubKeyA\\SubKeyA1": }
  registry_key { "${key_path}\\SubKeyA\\SubKeyA2": }
  registry_key { "${key_path}\\SubKeyB": }
  registry_key { "${key_path}\\SubKeyB\\SubKeyB1": }
  registry_key { "${key_path}\\SubKeyB\\SubKeyB2": }
  registry_key { "${key_path}\\SubKeyC": }
  registry_key { "${key_path}\\SubKeyC\\SubKeyC1": }
  registry_key { "${key_path}\\SubKeyC\\SubKeyC2": }
  registry_value { "${key_path}\\Value1": }
  registry_value { "${key_path}\\Value2": }
  registry_value { "${key_path}\\Value3": }
  registry_value { "${key_path}\\SubKeyA\\ValueA1": }
  registry_value { "${key_path}\\SubKeyA\\ValueA2": }
  registry_value { "${key_path}\\SubKeyA\\ValueA3": }
  registry_value { "${key_path}\\SubKeyB\\ValueB1": }
  registry_value { "${key_path}\\SubKeyB\\ValueB2": }
  registry_value { "${key_path}\\SubKeyB\\ValueB3": }
  registry_value { "${key_path}\\SubKeyC\\ValueC1": }
  registry_value { "${key_path}\\SubKeyC\\ValueC2": }
  registry_value { "${key_path}\\SubKeyC\\ValueC3": }
  registry_value { "${key_path}\\SubKeyA\\SubKeyA1\\ValueA1X": }
  registry_value { "${key_path}\\SubKeyA\\SubKeyA1\\ValueA1Y": }
  registry_value { "${key_path}\\SubKeyA\\SubKeyA1\\ValueA1Z": }
  registry_value { "${key_path}\\SubKeyA\\SubKeyA2\\ValueA2X": }
  registry_value { "${key_path}\\SubKeyA\\SubKeyA2\\ValueA2Y": }
  registry_value { "${key_path}\\SubKeyA\\SubKeyA2\\ValueA2Z": }
  registry_value { "${key_path}\\SubKeyB\\SubKeyB1\\ValueB1X": }
  registry_value { "${key_path}\\SubKeyB\\SubKeyB1\\ValueB1Y": }
  registry_value { "${key_path}\\SubKeyB\\SubKeyB1\\ValueB1Z": }
  registry_value { "${key_path}\\SubKeyB\\SubKeyB2\\ValueB2X": }
  registry_value { "${key_path}\\SubKeyB\\SubKeyB2\\ValueB2Y": }
  registry_value { "${key_path}\\SubKeyB\\SubKeyB2\\ValueB2Z": }
  registry_value { "${key_path}\\SubKeyC\\SubKeyC1\\ValueC1X": }
  registry_value { "${key_path}\\SubKeyC\\SubKeyC1\\ValueC1Y": }
  registry_value { "${key_path}\\SubKeyC\\SubKeyC1\\ValueC1Z": }
  registry_value { "${key_path}\\SubKeyC\\SubKeyC2\\ValueC2X": }
  registry_value { "${key_path}\\SubKeyC\\SubKeyC2\\ValueC2Y": }
  registry_value { "${key_path}\\SubKeyC\\SubKeyC2\\ValueC2Z": }
}
